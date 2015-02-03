#!/bin/env ruby
# encoding: utf-8

class ZalandoLibtcnative < FPM::Cookery::Recipe
  description "Tomcat native library using the Apache Portable Runtime for Zalando"

  version  "1.1.32"
  revision  0
  arch     "all"
  name     "zalando-libtcnative-1-#{version}"
  homepage "http://tomcat.apache.org/native-doc/"
  source   "http://archive.apache.org/dist/tomcat/tomcat-connectors/native/#{version}/source/tomcat-native-#{version}-src.tar.gz"
  maintainer    "Sören König <soeren.koenig@zalando.de>"
  section       "non-free/net"
  build_depends "libapr1.0-dev", "libssl-dev"
  depends       "libapr1", "libc6", "libssl1.0.0"

  def build
      Dir.chdir 'jni/native' do
        configure   :prefix => '/server/tomcat/7.0',
                    '--with-apr' => '/usr/lib/libapr-1.so.0',
                    '--with-java-home' => '/server/jdk/1.7.0'
        make
      end
  end

  def install
      make :install, 'DESTDIR' => destdir
  end

end
