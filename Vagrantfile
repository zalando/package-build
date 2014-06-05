# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "ubuntu12.04" do |c|
      boxname = "ubuntu12.04"
      c.vm.box = boxname
      c.vm.provision :shell, :path => "provision-#{boxname}.sh"
  end

  config.vm.define "centos6.5" do |c|
      boxname = "centos6.5"
      c.vm.box = boxname
      c.vm.provision :shell, :path => "provision-#{boxname}.sh"
  end

  
end
