# Package build box

## Requirements

[VirtualBox](https://www.virtualbox.org/)
[Vagrant](http://www.vagrantup.com/)

## Setup

    git clone ssh://git@stash.zalando.net:7999/system/vagrant-packagebuild.git
    vagrant-packagebuild
    vagrant up

## How to use

    vagrant ssh
    sudo -i
    root@precise64:/vagrant# cd fpm-recipes/redis/
    root@precise64:/vagrant/fpm-recipes/redis# fpm-cook