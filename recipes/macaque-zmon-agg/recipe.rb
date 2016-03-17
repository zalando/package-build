#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class MacaqueZmonAgg < FPM::Cookery::Recipe
  description "Macaque is a Zmon aggregator API, written in Go."
  GOPACKAGE = "github.com/zalando-techmonkeys/macaque-zmon-agg"

  name      "macaque-zmon-agg"
  version   "1.1.0"
  revision  201512221610

  homepage      "https://github.com/zalando-techmonkeys/macaque-zmon-agg"
  source        "https://github.com/zalando-techmonkeys/macaque-zmon-agg", :with => :git, :tag => "#{version}"
  maintainer    "Sandor Szücs <sandor.szuecs@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    # ugly hack, but we need the `develop` branch of github.com/gin-gonic/gin/
    safesystem "go get github.com/tools/godep"
    safesystem "cd ${GOPATH}/src/#{GOPACKAGE} && ${GOPATH}/bin/godep restore"
    safesystem "go install #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/macaque")
    (etc/"init.d/").install builddir("gobuild/src/#{GOPACKAGE}/scripts/macaque")
    (etc/"macaque/").install builddir("gobuild/src/#{GOPACKAGE}/config.yaml.sample")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
