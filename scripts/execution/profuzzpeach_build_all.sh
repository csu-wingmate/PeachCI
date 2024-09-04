#!/bin/bash

#export NO_CACHE="--no-cache"
#export MAKE_OPT="-j4"

cd $PFBENCH
cd subjects/FTP/lightftp
docker build . -t lightftp --build-arg MAKE_OPT $NO_CACHE



