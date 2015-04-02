#!/bin/bash
set -e

if [ -d tmp-build ]
then
    cd tmp-build && git pull origin master
else
    git clone git://git.code.sf.net/p/nagios/nrpe tmp-build && cd tmp-build
fi

patch < ../nagios-nrpe-plugin.patch
./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu --enable-command-args
cd ..
make deb
