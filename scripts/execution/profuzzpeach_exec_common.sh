#!/bin/bash
PROTOCOL=$1   #name of the protocol
RUNS=$2       #number of runs
SAVETO=$3     #path to folder keeping the results
FUZZER=$4     #fuzzer name (e.g., peach) -- this name must match the name of the fuzzer folder inside the Docker container
TIMEOUT=$5    #time for fuzzing
OPTIONS=$6    #all configured options for fuzzing
DELETE=$7

WORKDIR="/root"

#keep all container ids
fids=() ## fuzzer container ids
pids=() ## protocol container ids
#create one container for each run
for i in $(seq 1 ${RUNS}); do

  # 启动Docker容器
  fid=$(docker run --cpus=1 -itd ${FUZZER} /bin/bash)
  pid=$(docker run --cpus=1 -itd ${PROTOCOL} /bin/bash -c "cd ${WORKDIR} && ./run.sh")

  # protocol的IP地址
  EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${pid})

  # 检查是否传入了IP地址
  if [ -z "$EXTERNAL_IP" ]; then
    echo "Usage: $0 <IP-ADDRESS>"
    exit 1
  fi
  # XML文件路径
  XML_FILE="$PFBENCH/pits/${PROTOCOL}.xml"

  # 使用sed命令替换Host参数的值
  sed -i "s|<Param name=\"Host\" value=\".*\"/>|<Param name=\"Host\" value=\"$EXTERNAL_IP\"/>|" $XML_FILE

  # 将本地文件复制到Docker容器的指定位置
  docker cp $PFBENCH/pits/${PROTOCOL}.xml ${fid}:${WORKDIR}/tasks/${PROTOCOL}.xml

  # 在容器内执行测试脚本
  docker exec -itd ${fid} /bin/bash -c "timeout ${TIMEOUT} mono ${WORKDIR}/${FUZZER}/bin/peach.exe ${OPTIONS} ${PROTOCOL}.xml &"
  
  # 存储容器ID
  fids+=(${fid::12}) # 只存储容器ID的前12个字符
  pids+=(${pid::12}) # 只存储容器ID的前12个字符
done

flist="" #fuzzer docker list
for fid in ${fids[@]}; do
  flist+=" ${fid}"
done
#wait until all these dockers are stopped
printf "\n${FUZZER^^}: Fuzzing in progress ..."
printf "\n${FUZZER^^}: Waiting for the following containers to stop: ${flist}"
docker wait ${flist} > /dev/null
for fid in ${fids[@]}; do
  docker wait $fid > /dev/null
done
wait

plist="" #protocol docker list
for pid in ${pids[@]}; do
  plist+=" ${pid}"
done
#wait until all these dockers are stopped
printf "\n${PROTOCOL^^}: Waiting for the following containers to stop: ${plist}"
docker wait ${plist} > /dev/null
for pid in ${pids[@]}; do
  docker wait $pid > /dev/null
done
wait

#collect the fuzzing results from the containers
printf "\n${FUZZER^^}: Collecting results and save them to${SAVETO}"
index=1
ttime=`date +%Y-%m-%d-%T`
for fid in ${fids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container${fid}"
  
  # Copy the 'logs' folders from the container to the local directory
  docker cp ${fid}:/root/logs${SAVETO}/${index}_logs_${ttime}

  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${pid}"
    docker rm ${fid} # Remove container now that we don't need it
  fi
  index=$((index+1))
done

index=1
for pid in ${pids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container${pid}"
  
  # Copy the 'branch' folders from the container to the local directory
  docker cp ${pid}:/root/branch${SAVETO}/${index}_branch_${ttime}

  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${pid}"
    docker rm ${pid} # Remove container now that we don't need it
  fi
  index=$((index+1))
done



printf "\n${FUZZER^^}: I am done!\n"
