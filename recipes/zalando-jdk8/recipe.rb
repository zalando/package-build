#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK8 < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "1.8.0-112"
  revision   0
  arch      "all"
  name      "zalando-jdk8-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-8u#{version.split('-')[-1]}-linux-x64.tar.gz"
  # get checksums from https://www.oracle.com/webfolder/s/digest/8u112checksum.html
  sha256    "777bd7d5268408a5a94f5e366c2e43e720c6ce4fe8c59d9a71e2961e50d774a5"

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
