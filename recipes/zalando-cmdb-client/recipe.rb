#!/bin/env ruby
# encoding: utf-8

class ZalandoCMDBClient < FPM::Cookery::Recipe
  description "Python client library for CMDB REST API."

  name     "zalando-cmdb-client"
  version  "1.0.32"
  revision  201610281139
  arch     "all"

  homepage      "https://stash.zalando.net/projects/PYMODULES/repos/zalando-cmdb-client/browse"
  source        "https://stash.zalando.net/scm/pymodules/zalando-cmdb-client.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  platforms [:debian] do
    depends     "python-netaddr >= 0.7.5", "python-netifaces", "python-ordereddict", "python-yaml >= 3.10"
  end

  platforms [:ubuntu] do
      case FPM::Cookery::Facts.osmajorrelease
        when '16.04'
            depends     "python-netaddr >= 0.7.5", "python-netifaces", "python-yaml >= 3.10"
        when '14.04', '12.04'
            depends     "python-netaddr >= 0.7.5", "python-netifaces", "python-ordereddict", "python-yaml >= 3.10"
      end
  end

  platforms [:centos] do
    depends     "PyYAML >= 3.10", "python-argparse", "python-netaddr >= 0.7.5", "python-netifaces", "python-ordereddict", "python-setuptools"
  end

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
