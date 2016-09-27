#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class BaboonProxy < FPM::Cookery::Recipe
  description "Proxy server for the F5 API, written in Go."
  GOPACKAGE = "zalando.de/zalando/baboon-proxy"

  name      "baboon-proxy"
  version   "0.0.1"
  revision  201508251650

  homepage      "https://github.com/zalando/baboon-proxy"
  source        "https://github.com/zalando/baboon-proxy.git", :with => :git
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git"

  def build
    # Set up directory structure and $GOPATH.
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    # ugly hack, but we need the `develop` branch of github.com/gin-gonic/gin/
    safesystem "go get -v github.com/gin-gonic/gin/"
    safesystem "cd $GOPATH/src/github.com/gin-gonic/gin/ && git checkout develop"
    safesystem "go get -v #{GOPACKAGE}"
  end

  def install
    bin.install builddir("gobuild/bin/#{name}")
  end

  def after_install
    # For allowing more than one successive builds, there has some cleanup to be done.
    # If the build cookie is still existing on the second run, fpm-cook will stop and
    # not build the binary again.
    package_name = "#{name}-#{version}"
    build_cookie_name = (builddir/".build-cookie-#{package_name.gsub(/[^\w]/,'_')}").to_s
    rm_rf "#{build_cookie_name}", :verbose => true
  end
end
