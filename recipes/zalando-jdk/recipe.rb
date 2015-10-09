#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "1.7.0-80"
  revision   2
  arch      "all"
  name      "zalando-jdk-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-7u#{version[-2..-1]}-linux-x64.tar.gz"
  md5	    "6152f8a7561acf795ca4701daa10a965"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "libtcnative-1", "cronolog"

  def build
    jce_extras = [ "UnlimitedJCEPolicy/local_policy.jar", "UnlimitedJCEPolicy/US_export_policy.jar"  ]
    jce_extras.each { |extra|
        system "cp ../../cache/#{extra} ./jre/lib/security/#{extra.partition('/').last}"
    }
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
