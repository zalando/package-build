#!/bin/env ruby
# encoding: utf-8

class ZalandoZcloud < FPM::Cookery::Recipe
  description "Package containing CLI, agent and additional scripts for installing nodes via zCloud"

  name     "zalando-zcloud"
  version  "0.2.10"
  revision  201508101129
  arch     "all"

  homepage      "https://stash.zalando.net/projects/PYMODULES/repos/zalando-zcloud/browse"
  source        "https://stash.zalando.net/scm/pymodules/zalando-zcloud.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  platforms [:ubuntu, :debian] do
    depends     "zalando-cmdb-client", "python-paramiko >= 1.7.0"
  end

  platforms [:centos] do
    depends     "zalando-cmdb-client", "python-paramiko >= 1.7.0"
  end

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
