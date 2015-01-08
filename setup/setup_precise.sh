#!/bin/bash

sudo apt-get update
sudo apt-get -y install git-core curl ruby-dev # fpm-cook dependencies
sudo apt-get -y install htop vim rubygems
sudo gem install --no-ri --no-rdoc fpm fpm-cookery
