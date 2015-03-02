#!/bin/env ruby
# encoding: utf-8

class ZalandoJDKDBG < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando with debug symbols"

  version   "1.7.0-76"
  revision   0
  arch      "all"
  name      "zalando-jdk-dbg-#{version}"
  homepage  "http://www.oracle.com/"
  source    "file://.cache/jdk#{version.gsub('-','_')}/"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "libtcnative-1", "cronolog"

  def build
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
