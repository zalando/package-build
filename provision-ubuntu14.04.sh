#!/bin/bash

apt-get update

apt-get install -y vim ruby ruby-dev rubygems1.9.1 python-setuptools
apt-get install -y git-core curl # fpm-cook dependencies
gem install --no-rdoc --no-ri fpm fpm-cookery

