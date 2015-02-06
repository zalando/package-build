#!/bin/env ruby
# encoding: utf-8

class ZalandoTomcat < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version  "7.0.57"
  revision  1
  arch     "all"
  name     "zalando-tomcat-#{version}"
  homepage "http://tomcat.apache.org/"
  source   "http://archive.apache.org/dist/tomcat/tomcat-7/v#{version}/bin/apache-tomcat-#{version}.tar.gz"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section  "non-free/net"
  depends  "libtcnative-1", "cronolog"

  def build
    extras = [ "catalina-jmx-remote.jar", "catalina-ws.jar", "tomcat-juli-adapters.jar", "tomcat-juli.jar" ]
    extras.each { |extra|
        system "wget http://archive.apache.org/dist/tomcat/tomcat-7/v#{version}/bin/extras/#{extra} -O lib/#{extra}"
    }
  end

  def install
     root("/server/tomcat/#{version}").install Dir["*"]
  end

end
