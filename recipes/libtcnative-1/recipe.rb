#!/bin/env ruby
# encoding: utf-8

class Libtcnative < FPM::Cookery::Recipe
  description "Tomcat native library using the Apache Portable Runtime for Zalando"

  version       "1.1.32"
  revision      0
  arch          "amd64"
  name          "libtcnative-1"
  homepage      "http://tomcat.apache.org/native-doc/"
  source        "http://archive.apache.org/dist/tomcat/tomcat-connectors/native/#{version}/source/tomcat-native-#{version}-src.tar.gz"
  maintainer    "Sören König <soeren.koenig@zalando.de>"
  section       "java"
  build_depends "libapr1-dev", "libssl-dev", "openjdk-7-jdk"
  depends       "libapr1", "libc6", "libssl1.0.0"

  def build
      Dir.chdir 'jni/native' do
        configure   :prefix => '/usr',
		    'with-apr' => '/usr/bin/apr-1-config',
		    'with-ssl' => 'yes',
		    'with-java-home' => '/usr/lib/jvm/java-7-openjdk-amd64'
        make
      end
  end

  def install
      Dir.chdir 'jni/native' do
      	make :install, 'DESTDIR' => destdir
      end
  end

end
