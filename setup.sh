#!/bin/sh

set -x

cd iotivity_sample
git clone -b 1.1_darwin https://github.com/runtimeinc/iotivity
cd iotivity
git clone https://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor
cd extlibs/tinycbor/tinycbor
git checkout 47a78569c0
cd ../../..
ln -s out/ios ios
tools/darwin/build-ios.sh
tools/darwin/mkfwk_ios.sh 
