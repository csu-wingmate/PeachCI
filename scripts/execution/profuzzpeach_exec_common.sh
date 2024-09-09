#!/bin/bash
PROTOCOL=$1   #name of the protocol
RUNS=$2       #number of runs
SAVETO=$3     #path to folder keeping the results
FUZZER=$4     #fuzzer name (e.g., peach) 
TIMEOUT=$5    #time for fuzzing
DELETE=$6

WORKDIR="/root"

#keep all container ids
fids=() ## fuzzer container ids
pids=() ## protocol container ids
#create one container for each run
for i in $(seq 1 ${RUNS}); do

  # 启动Docker容器
  fid=$(docker run --cpus=1 -d -it ${FUZZER} /bin/bash)
  pid=$(docker run --cpus=1 -d -it ${PROTOCOL} /bin/bash -c "cd ${WORKDIR} && ./run.sh ${FUZZER}")

  # protocol的IP地址
  EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${pid})

  # XML文件路径
  XML_FILE="$PFBENCH/pits/${PROTOCOL}.xml"

  # 使用sed命令替换Host参数的值
  sed -i "s|<Param name=\"Host\" value=\".*\"/>|<Param name=\"Host\" value=\"$EXTERNAL_IP\"/>|" $XML_FILE

  # 将本地文件复制到Docker容器的指定位置
  docker cp $PFBENCH/pits/${PROTOCOL}.xml ${fid}:${WORKDIR}/tasks/${PROTOCOL}.xml

  # 在容器内执行测试脚本
  docker exec -d ${fid} /bin/bash -c "timeout ${TIMEOUT} mono ./${FUZZER}/bin/peach.exe ./tasks/${PROTOCOL}.xml"
  
  # 存储容器ID
  fids+=(${fid::12}) # 只存储容器ID的前12个字符
  pids+=(${pid::12}) # 只存储容器ID的前12个字符
done

# 合并fuzzer和protocol容器的ID列表
all_containers=("${fids[@]}" "${pids[@]}")

# 将所有容器ID转换为字符串，用于docker wait命令
container_list=$(printf "%s " "${all_containers[@]}")

# 等待所有容器停止
printf "\nWaiting for all containers to stop: ${container_list}"
docker wait ${container_list} > /dev/null

# 可以省略以下循环，因为上面的docker wait已经等待所有容器
# for container_id in "${all_containers[@]}"; do
#   docker wait $container_id > /dev/null
# done

# 等待所有后台进程结束
wait

#collect the fuzzing results from the containers
printf "\n${FUZZER^^}: Collecting results and save them to ${SAVETO}"
index=1
for fid in ${fids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container ${fid}"
  
  # Copy the 'logs' folders from the container to the local directory
  docker cp ${fid}:/root/logs ${SAVETO}/${FUZZER}_${index}_logs

  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${pid}"
    docker rm ${fid} # Remove container now that we don't need it
  fi
  index=$((index+1))
done

index=1
for pid in ${pids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container ${pid}"
  
  # Copy the 'branch' folders from the container to the local directory
  docker cp ${pid}:/root/branch ${SAVETO}/${FUZZER}_${index}_branch

  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${pid}"
    docker rm ${pid} # Remove container now that we don't need it
  fi
  index=$((index+1))
done



printf "\n${FUZZER^^}: I am done!\n"
