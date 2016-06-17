#!/bin/bash

apt-get build-dep -y --no-install-recommends --no-install-suggests nagios-nrpe
ln -fs /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/libssl.so

