#!/bin/env ruby
# encoding: utf-8

class MacaqueZmonAgg < FPM::Cookery::Recipe
  description "Macaque is a Zmon aggregator API, written in Go."
  GOPACKAGE = "macaque-zmon-agg"

  name      "macaque-zmon-agg"
  version   "1.0.0"
  revision  201509281709

  homepage      "https://github.com/zalando-techmonkeys/macaque-zmon-agg"
  source        "https://github.com/zalando-techmonkeys/macaque-zmon-agg", :with => :git, :tag => "1.0.0"
  maintainer    "Sandor Szücs <sandor.szuecs@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "go get -v #{GOPACKAGE}"
  end

  def install
    bin.install builddir("gobuild/bin/macaque")
    #rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    #rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
