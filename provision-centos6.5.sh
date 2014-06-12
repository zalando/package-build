#!/bin/bash


yum install -y ruby ruby-devel ruby-ri ruby-rdoc rubygems python-setuptools
gem install --no-rdoc --no-ri fpm

yum install -y vim

if ! id skoenig &>/dev/null
then
    useradd -m -s /bin/bash -G wheel skoenig
    mkdir -p /home/skoenig/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG5euLJH4vnoH+iv18L04GltkcNmisR9gnRsqVI6i5txc07UsJWmCmCfh1kG8uhILUlgRUASArXXYhP2ZZE8zslxsV8y216ts8Sak/a89KNCtKB3rZw7bRoIdJ+MX2KhJBNQUoDgytbMUDOihbU6Mh5iFRk95k2Rm4jb39rTgwvGPrBBGn00xj1UZ77N/ueHNguV/sQiKhClXsItvHxzcJUUe6zgz6ExfM5nl31PqecZjUg7TX8KDmk2pV1okZkJncOMlnT3EwUv4tLw9gJKJNQBE8bC/QkcF572Et0p8P4A3BzRgfKLlIGyLTFP21tu1uE6ldHdb+AIwoncWRbqd7 skoenig' > /home/skoenig/.ssh/authorized_keys
    chown -R skoenig: /home/skoenig/.ssh
    chmod 700 /home/skoenig/.ssh
    chmod 600 /home/skoenig/.ssh/authorized_keys
fi

