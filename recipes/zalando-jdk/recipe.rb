#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "1.7.0-76"
  revision   0
  arch      "all"
  name      "zalando-jdk-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-7u#{version[-2..-1]}-linux-x64.tar.gz"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "zalando-libtcnative-1-1.1.32", "cronolog"

  def build
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
