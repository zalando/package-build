#!/bin/env ruby
# encoding: utf-8

class ZalandoLDAPDN < FPM::Cookery::Recipe
  description "Helper library to handle LDAP \"dn\" strings."

  name     "zalando-ldapdn"
  version  "0.0.1"
  revision  201802081353
  arch     "all"

  homepage      "https://github.bus.zalan.do/legacy-platform/zalando-ldapdn"
  source        "https://github.bus.zalan.do/legacy-platform/zalando-ldapdn.git", :with => :git, :branch => "master"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile --prefix=/usr/local'
  end
end
