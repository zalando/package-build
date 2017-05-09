#!/bin/env ruby
# encoding: utf-8

class ZalandoZcloud < FPM::Cookery::Recipe
  description "Package containing CLI, agent and additional scripts for installing nodes via zCloud"

  name     "zalando-zcloud"
  version  "0.3.7"
  revision  201705091159
  arch     "all"

  homepage      "https://github.bus.zalan.do/team-ghost/zalando-zcloud"
  source        "https://github.bus.zalan.do/team-ghost/zalando-zcloud.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  platforms [:ubuntu, :debian] do
    depends     "zalando-cmdb-client", "python-paramiko >= 1.7.0", "python-libvirt"
  end

  platforms [:centos] do
    depends     "zalando-cmdb-client", "python-paramiko >= 1.7.0", "libvirt-python"
  end

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile --prefix=/usr/local'
  end
end
