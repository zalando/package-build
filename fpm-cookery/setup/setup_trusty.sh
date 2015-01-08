#!/bin/bash

sudo apt-get update
sudo apt-get -y install git-core curl # fpm-cook dependencies
sudo apt-get -y install htop vim rubygems1.9.1 ruby-dev
sudo gem install --no-ri --no-rdoc fpm fpm-cookery
