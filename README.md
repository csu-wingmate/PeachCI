# profuzzpeach
## setup
export PFBENCH=$(pwd)

export PATH=$PATH:$PFBENCH/scripts/execution:$PFBENCH/scripts/analysis

profuzzpeach_build_all.sh

profuzzpeach_exec_common.sh lightftp 1 results-lightftp peach 30
