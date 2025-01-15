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

            cd $CIPATH
            mkdir results-lightftp

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh lightftp $NUM_CONTAINERS results-lightftp peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh lightftp $NUM_CONTAINERS results-lightftp peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh lightftp $NUM_CONTAINERS results-lightftp charon $TIMEOUT 1
            fi

        fi


##### DNS #####

        if [[ $TARGET == "dnsmasq" ]] || [[ $TARGET == "all" ]]
        then

            cd $CIPATH
            mkdir results-dnsmasq

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh dnsmasq $NUM_CONTAINERS results-dnsmasq peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh dnsmasq $NUM_CONTAINERS results-dnsmasq peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh dnsmasq $NUM_CONTAINERS results-dnsmasq charon $TIMEOUT 1
            fi

        fi



##### DDS #####

        if [[ $TARGET == "cyclonedds" ]] || [[ $TARGET == "all" ]]
        then

            cd $CIPATH
            mkdir results-cyclonedds

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh cyclonedds $NUM_CONTAINERS results-cyclonedds peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh cyclonedds $NUM_CONTAINERS results-cyclonedds peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh cyclonedds $NUM_CONTAINERS results-cyclonedds charon $TIMEOUT 1
            fi

        fi


        

##### COAP #####

        if [[ $TARGET == "libcoap" ]] || [[ $TARGET == "all" ]]
        then

            cd $CIPATH
            mkdir results-libcoap

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh libcoap $NUM_CONTAINERS results-libcoap peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh libcoap $NUM_CONTAINERS results-libcoap peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh libcoap $NUM_CONTAINERS results-libcoap charon $TIMEOUT 1
            fi

        fi

##### TLS #####

        if [[ $TARGET == "openssl" ]] || [[ $TARGET == "all" ]]
        then

            cd $CIPATH
            mkdir results-openssl

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh openssl $NUM_CONTAINERS results-openssl peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh openssl $NUM_CONTAINERS results-openssl peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh openssl $NUM_CONTAINERS results-openssl charon $TIMEOUT 1
            fi

        fi


##### HTTP #####

        if [[ $TARGET == "apachehttpd" ]] || [[ $TARGET == "all" ]]
        then

            cd $CIPATH
            mkdir results-apachehttpd

            if [[ $FUZZER == "peach" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh apachehttpd $NUM_CONTAINERS results-apachehttpd peach $TIMEOUT 1
            fi

            if [[ $FUZZER == "peachstar" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh apachehttpd $NUM_CONTAINERS results-apachehttpd peachstar $TIMEOUT 1
            fi
            if [[ $FUZZER == "charon" ]] || [[ $FUZZER == "all" ]]
            then
                profuzzbench_exec_common.sh apachehttpd $NUM_CONTAINERS results-apachehttpd charon $TIMEOUT 1
            fi

        fi



    done
done

