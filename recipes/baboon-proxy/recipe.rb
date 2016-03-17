#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class BaboonProxy < FPM::Cookery::Recipe
  description "Proxy server for the F5 API, written in Go."
  GOPACKAGE = "zalando.de/techmonkeys/baboon-proxy"

  name      "baboon-proxy"
  version   "0.0.1"
  revision  201508251650

  homepage      "https://stash.zalando.net/projects/SYSTEM/repos/baboon-proxy/browse"
  source        "https://stash.zalando.net/scm/system/baboon-proxy.git", :with => :git
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git"

  def build
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
    bin.install builddir("gobuild/bin/baboon-proxy")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
