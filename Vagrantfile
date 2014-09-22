# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "precise64" do |cfg|
    cfg.vm.box = "hashicorp/precise64"
    cfg.vm.provision "shell", path: "setup/setup_precise.sh"
  end

  config.vm.define "centos_65" do |cfg|
    cfg.vm.box = "centos_65"
    cfg.vm.provision "shell", path: "setup/setup_centos65.sh"
  end
end
