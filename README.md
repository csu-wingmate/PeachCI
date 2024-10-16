# profuzzpeach
## setup
export PFBENCH=$(pwd)
export PATH=$PATH:$PFBENCH/scripts/execution:$PFBENCH/scripts/analysis

profuzzpeach_build_all.sh

profuzzpeach_exe_common.sh lightftp 1 resuts-lightftp peach 30
