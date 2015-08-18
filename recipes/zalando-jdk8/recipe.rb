#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK8 < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "1.8.0-51"
  revision   1
  arch      "all"
  name      "zalando-jdk8-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-8u#{version[-2..-1]}-linux-x64.tar.gz"
  md5	    "b34ff02c5d98b6f372288c17e96c51cf"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "libtcnative-1", "cronolog"

  def build
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
