# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
    end

    File.foreach("boxes") do |box|
        name, url = box.split(" ").map(&:strip)
        config.vm.define name do |c|
            c.vm.box = name
            c.vm.hostname = name
            provision_script = "provision.sh"
            if File.file?("provision-#{name}.sh")
                provision_script = "provision-#{name}.sh"
            end
            c.vm.provision :shell, :path => provision_script
        end
    end
  
end
