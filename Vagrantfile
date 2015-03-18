# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    boxes = {
        'ubuntu12.04' => 'https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box',
        'ubuntu14.04' => 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box',
        'centos6.5' => 'https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box'
    }

    boxes.each do |name, url|
        config.vm.define name do |c|
            c.vm.box = name
            c.vm.box_url = url
            c.vm.hostname = name
            provision_script = "provision.sh"
            if File.file?("provision-#{name}.sh")
                provision_script = "provision-#{name}.sh"
            end
            c.vm.provision :shell, :path => provision_script
        end
    end
end
