#!/bin/bash

# Download kernel source
cd /usr/src
wget -O rpi-`uname -r`.tar.gz https://github.com/raspberrypi/linux/tarball/rpi-3.6.y
rm -rf raspberrypi-*
tar xzf rpi-`uname -r`.tar.gz
cd raspberrypi-*
KSRC=`pwd`
pushd /lib/modules/`uname -r`
rm source
rm build
ln -s ${KSRC} source
ln -s ${KSRC} build
popd
pushd /usr/src
rm linux-`uname -r`
rm linux
ln -s ${KSRC} linux-`uname -r`
ln -s ${KSRC} linux
popd
zcat /proc/config.gz > .config
make oldconfig
make modules_prepare
wget -O Module.symvers https://github.com/raspberrypi/firmware/raw/master/extra/Module.symvers
