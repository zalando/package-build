#!/bin/env ruby
# encoding: utf-8

class PythonNetaddr < FPM::Cookery::PythonRecipe
  description "Pythonic manipulation of IPv4, IPv6, CIDR, EUI and MAC network addresses"

  name      "netaddr"
  version   "0.7.15"
  revision  0
  arch      "all"
  homepage  "https://github.com/drkjam/netaddr/"

  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends ["python-setuptools"]
  depends       ["python"]
end
