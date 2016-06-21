#!/bin/bash

apt-get build-dep -y --no-install-recommends --no-install-suggests memcached
apt-get install -y --no-install-recommends --no-install-suggests libsasl2-dev
