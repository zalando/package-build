#!/bin/bash

yum install -y ruby ruby-devel ruby-ri ruby-rdoc rubygems python-setuptools git curl vim-common
gem install --no-rdoc --no-ri fpm fpm-cookery

source /vagrant/build-recipe.sh
