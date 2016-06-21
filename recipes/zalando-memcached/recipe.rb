#!/bin/env ruby
# encoding: utf-8

class ZalandoMemcached < FPM::Cookery::Recipe
  description 'A high-performance memory object caching system'

  version     '1.4.17'
  revision    '1'
  name        'zalando-memcached'

  homepage    'https://www.memcached.org/'
  source      "https://www.memcached.org/files/memcached-#{version}.tar.gz"
  sha256      'd9173ef6d99ba798c982ea4566cb4f0e64eb23859fdbf9926a89999d8cdc0458'
  maintainer  'Sören König <soeren.koenig@zalando.de>'

  section     'web'
  replaces    'memcached'
  conflicts   'memcached'

  platforms [:ubuntu] do
    depends 'libc6' 'libevent-2.0-5' 'libsasl2-2' 'perl' 'lsb-base' 'adduser'

    def build
        configure :prefix => prefix,
            'enable-sasl' => true

        make
    end

    def install
        make :install, 'DESTDIR' => destdir
        root.install workdir('content/etc/')
        root.install workdir('content/usr/')
    end

  end

  platforms [:debian, :centos, :redhat] do
    FPM::Cookery::Log.error("Not building for this platform")
    exit 1
  end

end
