#!/bin/bash

#export NO_CACHE="--no-cache"
#export MAKE_OPT="-j4"

cd $PFBENCH
cd fuzzer/Peach
docker build . -t peach --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd fuzzer/PeachStar
docker build . -t peachstar --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd fuzzer/Charon
docker build . -t charon --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/FTP/lightftp
docker build . -t lightftp --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/DNS/dnsmasq
docker build . -t dnsmasq --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/COAP/libcoap
docker build . -t libcoap --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/DDS/cyclonedds
docker build . -t cyclonedds --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/TLS/openssl
docker build . -t openssl --build-arg MAKE_OPT $NO_CACHE

cd $PFBENCH
cd subjects/HTTP/apachehttpd
docker build . -t apachehttpd --build-arg MAKE_OPT $NO_CACHE
