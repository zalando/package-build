# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'pathname'

ROOT = Pathname.new(__FILE__).expand_path.dirname

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    Dir.foreach(ROOT.join('docker/')) do |dist|
        next if dist == '.' or dist == '..'

        config.vm.define dist do |machine|
            machine.vm.provider 'docker' do |docker|
                docker.build_dir = ROOT.join("docker/#{dist}")
                docker.build_args = ["--rm=true", "--tag=package_build/#{dist}"]
                docker.create_args = ["--rm=true"]
            end
        end
    end
end
