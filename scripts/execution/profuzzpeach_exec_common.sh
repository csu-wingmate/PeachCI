#!/bin/bash

DOCIMAGE=$1   #name of the docker image
RUNS=$2       #number of runs
SAVETO=$3     #path to folder keeping the results
FUZZER=$4     #fuzzer name (e.g., aflnet) -- this name must match the name of the fuzzer folder inside the Docker container
TIMEOUT=$5    #time for fuzzing
DELETE=$6

WORKDIR="/root/experiments"

#keep all container ids
cids=()

#create one container for each run
for i in $(seq 1$RUNS); do
  # Copy the local file ${PIT} to the container's WORKDIR
  container_pit_path="${WORKDIR}/tasks/${PIT##*/}"
  docker cp ${PIT} $DOCIMAGE:${container_pit_path}
  
  # Run the container and execute the script with the required arguments
  id=$(docker run --cpus=1 -d -it $DOCIMAGE /bin/bash -c "cd ${WORKDIR} && ./${FUZZER}_parallel_out.sh ${TIMEOUT} ${container_pit_path}")
  cids+=(${id::12}) #store only the first 12 characters of a container ID
done

dlist="" #docker list
for id in ${cids[@]}; do
  dlist+=" ${id}"
done

#wait until all these dockers are stopped
printf "\n${FUZZER^^}: Fuzzing in progress ..."
printf "\n${FUZZER^^}: Waiting for the following containers to stop: ${dlist}"
docker wait ${dlist} > /dev/null
wait

#collect the fuzzing results from the containers
printf "\n${FUZZER^^}: Collecting results and save them to${SAVETO}"
index=1
for id in ${cids[@]}; do
  printf "\n${FUZZER^^}: Collecting results from container${id}"
  
  # Copy the 'branch' and 'logs' folders from the container to the local directory
  docker cp ${id}:/root/experiments/branch${SAVETO}/${index}_branch
  docker cp ${id}:/root/experiments/logs${SAVETO}/${index}_logs
  
  if [ ! -z $DELETE ]; then
    printf "\nDeleting ${id}"
    docker rm ${id} # Remove container now that we don't need it
  fi
  index=$((index+1))
done


printf "\n${FUZZER^^}: I am done!\n"
