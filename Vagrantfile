# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Ubuntu 12.04 amd64
  config.vm.define "precise64" do |cfg|
    cfg.vm.box = "hashicorp/precise64"
    cfg.vm.provision "shell", path: "setup/setup_precise.sh"
  end

  # Ubuntu 14.04 amd64
  config.vm.define "trusty64" do |cfg|
    cfg.vm.box = "ubuntu/trusty64"
    cfg.vm.provision "shell", path: "setup/setup_trusty.sh"
  end

  # CentOS 6.5
  config.vm.define "centos_65" do |cfg|
    cfg.vm.box = "glarizza/centos_65"
    cfg.vm.provision "shell", path: "setup/setup_centos65.sh"
  end
end
