#!/bin/env ruby
# encoding: utf-8

class ZalandoFabricSystem < FPM::Cookery::Recipe
  description "set of customized fabric scripts for Team Platform/System"

  name      "zalando-fabric-system"
  version   "0.1.4"
  revision  201504022017
  arch      "all"

  homepage      "https://stash.zalando.net/projects/PYMODULES/repos/zalando-fabric-system/browse"
  source        "https://stash.zalando.net/scm/pymodules/zalando-fabric-system.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  platforms [:ubuntu, :debian] do
    depends "fabric == 1.8.0", "python-cuisine == 0.6.5", "python-ldap", "python-netaddr == 0.7.10"
  end

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
# test
