#!/bin/bash
# tested on Debian Jessie

if grep -qi Debian /etc/os-release
then
    sudo apt-get update
    sudo apt-get install virtualbox virtualbox-guest-additions-iso

    echo "installing a matching version of vagrant"
    wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
    sudo dpkg -i vagrant_1.4.3_x86_64.deb
else
    echo "You have to install virtualbox and vagrant manually"
fi

# HINT: for using KVM provider use plugin https://github.com/adrahon/vagrant-kvm
# apt-get install qemu qemu-kvm build-essential ruby2.0-dev libvirt-dev libxslt1-dev libxml2-dev
#vagrant box list | grep -q 'ubuntu12.04\s*(kvm)' || vagrant box add ubuntu12.04 https://vagrant-kvm-boxes.s3.amazonaws.com/precise64-kvm.box
#vagrant box list | grep -q 'centos6.4\s*(kvm)' || vagrant box add centos6.4 https://vagrant-kvm-boxes.s3.amazonaws.com/centos64-amd64-kvm.box

echo "add our build boxes..."
while read name url
do
    vagrant box list | grep -q "$name\s*(virtualbox" || vagrant box add $name $url
done < boxes

