# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
    end

    File.foreach("boxes") do |boxname|
        boxname.chomp!
        config.vm.define boxname do |c|
            c.vm.box = boxname
            provision_script = "provision.sh"
            if File.file?("provision-#{boxname}.sh")
                provision_script = "provision-#{boxname}.sh"
            end
            c.vm.provision :shell, :path => provision_script
        end
    end
  
end
