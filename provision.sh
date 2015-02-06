#!/bin/bash

if nc -zw 3 repo.zalando 3142
then
    cat > /etc/apt/apt.conf.d/01proxy << EOF
Acquire::http::Proxy "http://repo.zalando:3142";
Acquire::https::Proxy "https://";
EOF
fi

apt-get update

apt-get install -y vim ruby ruby-dev python-setuptools
apt-get install -y git-core curl # fpm-cook dependencies
gem install --no-rdoc --no-ri fpm fpm-cookery

