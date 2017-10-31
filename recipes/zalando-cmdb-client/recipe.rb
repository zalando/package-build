#!/bin/env ruby
# encoding: utf-8

class ZalandoCMDBClient < FPM::Cookery::Recipe
  description "Python client library for CMDB REST API."

  name     "zalando-cmdb-client"
  version  "1.1.1"
  revision  201710271520
  arch     "all"

  homepage      "https://github.bus.zalan.do/team-ghost/zalando-cmdb-client"
  source        "https://github.bus.zalan.do/team-ghost/zalando-cmdb-client.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  platforms [:centos] do
    depends     "python-argparse", "python-setuptools"
  end

  def build
    safesystem 'python setup.py build'
  end

  def install
    safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
