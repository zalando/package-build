#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK8 < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "1.8.0-66"
  revision   2
  arch      "all"
  name      "zalando-jdk8-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-8u#{version[-2..-1]}-linux-x64.tar.gz"
  sha256    "7e95ad5fa1c75bc65d54aaac9e9986063d0a442f39a53f77909b044cef63dc0a"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "libtcnative-1", "cronolog"

  def build
    jce_extras = [ "UnlimitedJCEPolicyJDK8/local_policy.jar", "UnlimitedJCEPolicyJDK8/US_export_policy.jar"  ]
    jce_extras.each { |extra|
        system "cp ../../cache/#{extra} ./jre/lib/security/#{extra.partition('/').last}"
    }
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
