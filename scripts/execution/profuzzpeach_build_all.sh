#!/bin/bash

#export NO_CACHE="--no-cache"
#export MAKE_OPT="-j4"

cd $PFBENCH
cd subjects/FTP/LightFTP
docker build . -t lightftp --build-arg MAKE_OPT $NO_CACHE
docker build . -t lightftp-stateafl -f Dockerfile-stateafl --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/DNS/Dnsmasq
docker build . -t dnsmasq --build-arg MAKE_OPT $NO_CACHE
docker build . -t dnsmasq-stateafl -f Dockerfile-stateafl --build-arg MAKE_OPT $NO_CACHE

