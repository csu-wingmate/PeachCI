#!/bin/bash

export NUM_CONTAINERS="${NUM_CONTAINERS:-2}"
export TIMEOUT="${TIMEOUT:-86400}"

export TARGET_LIST=$1
export FUZZER_LIST=$2

if [[ "x$TARGET_LIST" == "x" ]] || [[ "x$FUZZER_LIST" == "x" ]]
then
    echo "Usage: $0 TARGET FUZZER"
    exit 1
fi

echo
echo "# NUM_CONTAINERS: ${NUM_CONTAINERS}"
echo "# TIMEOUT: ${TIMEOUT} s"
echo "# TARGET LIST: ${TARGET_LIST}"
echo "# FUZZER LIST: ${FUZZER_LIST}"
echo

for FUZZER in $(echo $FUZZER_LIST | sed "s/,/ /g")
do

    for TARGET in $(echo $TARGET_LIST | sed "s/,/ /g")
    do

        echo
        echo "***** RUNNING $FUZZER ON $TARGET *****"
        echo

##### FTP #####

        if [[ $TARGET == "lightftp" ]] || [[ $TARGET == "all" ]]
        then

            cd $PFBENCH
            mkdir results-lightftp

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh lightftp $NUM_CONTAINERS results-lightftp peach $TIMEOUT 
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh lightftp $NUM_CONTAINERS results-lightftp peachstar $TIMEOUT -pro
            fi

        fi

##### HTTP #####

        if [[ $TARGET == "apachehttpd" ]] || [[ $TARGET == "all" ]]
        then

            cd $PFBENCH
            mkdir results-apachehttpd

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh apachehttpd $NUM_CONTAINERS results-apachehttpd peach $TIMEOUT 
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh apachehttpd $NUM_CONTAINERS results-apachehttpd peachstar $TIMEOUT -pro
            fi

        fi



    done
done

