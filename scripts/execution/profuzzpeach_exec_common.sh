#!/bin/bash

DOCIMAGE=$1   #name of the docker image
PROTOCOL=$2   #name of the protocol
RUNS=$3       #number of runs
SAVETO=$4     #path to folder keeping the results
FUZZER=$5     #fuzzer name (e.g., aflnet) -- this name must match the name of the fuzzer folder inside the Docker container
TIMEOUT=$6    #time for fuzzing
DELETE=$7

WORKDIR="/root/experiments"

#keep all container ids
cids=()

#create one container for each run
for i in $(seq 1 ${RUNS}); do

  # 启动Docker容器
  id=$(docker run --cpus=1 -itd ${DOCIMAGE} /bin/bash)
  
  # 将本地文件复制到Docker容器的指定位置
  docker cp $PFBENCH/subjects/${PROTOCOL}/${DOCIMAGE}/${DOCIMAGE}_task.xml ${id}:${WORKDIR}/tasks/${DOCIMAGE}_task.xml
  
  # 在容器内执行测试脚本
  docker exec -itd ${id} /bin/bash -c "cd ${WORKDIR} && ./${FUZZER}_out.sh ${TIMEOUT} ${DOCIMAGE}_task.xml"
  
  # 存储容器ID
  cids+=(${id::12}) # 只存储容器ID的前12个字符
done

dlist="" #docker list
for id in ${cids[@]}; do
  dlist+=" ${id}"
done

#wait until all these dockers are stopped
printf "\n${FUZZER^^}: Fuzzing in progress ..."
printf "\n${FUZZER^^}: Waiting for the following containers to stop: ${dlist}"
docker wait ${dlist} > /dev/null
for id in ${cids[@]}; do
  docker wait $id > /dev/null
done
wait

#collect the fuzzing results from the containers
printf "\n${FUZZER^^}: Collecting results and save them to${SAVETO}"
index=1
for id in ${cids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container${id}"
  
  # Copy the 'branch' and 'logs' folders from the container to the local directory
  docker cp ${id}:/root/experiments/branch ${SAVETO}/${FUZZER}_${index}_branch
  docker cp ${id}:/root/experiments/logs ${SAVETO}/${FUZZER}_${index}_logs
  
  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${id}"
    docker rm ${id} # Remove container now that we don't need it
  fi
  index=$((index+1))
done


printf "\n${FUZZER^^}: I am done!\n"
