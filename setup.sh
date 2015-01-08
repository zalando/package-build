#!/bin/bash
# tested on debian jessie

if grep -qi Debian /etc/os-release
then

    echo "installing a current version of Virtualbox as described on https://www.virtualbox.org/wiki/Linux_Downloads"
    echo 'deb http://download.virtualbox.org/virtualbox/debian wheezy contrib' | sudo tee /etc/apt/sources.list.d/virtualbox.list
    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install virtualbox-4.3

    echo "installing a matching version of vagrant"
    wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
    sudo dpkg -i vagrant_1.4.3_x86_64.deb
else
    echo "You have to install virtualbox and vagrant manually"
if

# HINT: for using KVM provider use plugin https://github.com/adrahon/vagrant-kvm
# apt-get install qemu qemu-kvm build-essential ruby2.0-dev libvirt-dev libxslt1-dev libxml2-dev
#vagrant box list | grep -q 'ubuntu12.04\s*(kvm)' || vagrant box add ubuntu12.04 https://vagrant-kvm-boxes.s3.amazonaws.com/precise64-kvm.box
#vagrant box list | grep -q 'centos6.4\s*(kvm)' || vagrant box add centos6.4 https://vagrant-kvm-boxes.s3.amazonaws.com/centos64-amd64-kvm.box

echo "add our target boxes..."
vagrant box list | grep -q 'ubuntu12.04\s*(virtualbox)' || vagrant box add ubuntu12.04 https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box
vagrant box list | grep -q 'ubuntu14.04\s*(virtualbox)' || vagrant box add ubuntu14.04 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
vagrant box list | grep -q 'centos6.5\s*(virtualbox)' || vagrant box add centos6.5 https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box

