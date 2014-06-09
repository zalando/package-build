# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    File.foreach("boxes") do |boxname|
        boxname.chomp!
        config.vm.define boxname do |c|
            c.vm.box = boxname
            c.vm.provision :shell, :path => "provision-#{boxname}.sh"
        end
    end
  
end
