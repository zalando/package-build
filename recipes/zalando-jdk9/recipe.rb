#!/bin/env ruby
# encoding: utf-8

class ZalandoJDK9 < FPM::Cookery::Recipe
  description "Tomcat meta package for Zalando"

  version   "9.0.1+11"
  revision   0
  arch      "all"
  name      "zalando-jdk9-#{version}"
  homepage  "http://www.oracle.com/"
  source    "cache/jdk-#{version}_linux-x64_bin.tar.gz"
  # get checksums from https://www.oracle.com/webfolder/s/digest/9-0-1checksum.html
  sha256    "2cdaf0ff92d0829b510edd883a4ac8322c02f2fc1beae95d048b6716076bc014"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section   "non-free/net"
  depends   "libtcnative-1", "cronolog"

  def build
  end

  def install
     root("/server/jdk/#{version.gsub('-','_')}").install Dir["*"]
  end

end
