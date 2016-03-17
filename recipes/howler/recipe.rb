#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class Howler < FPM::Cookery::Recipe
  description "Howler: waits to hear something in the Marathon Event Bus and shouts it to the other monkeys"
  GOPACKAGE = "github.com/zalando-techmonkeys/howler"

  name      "howler"
  version   "0.0.8"
  revision  201602111024

  homepage      "https://github.com/zalando-techmonkeys/howler"
  source        "https://github.com/zalando-techmonkeys/howler", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "go get github.com/tools/godep"
    safesystem "cd ${GOPATH}/src/#{GOPACKAGE} && ${GOPATH}/bin/godep restore"
    safesystem "go install -tags zalando #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/howler")
    (etc/"init.d/").install builddir("gobuild/src/#{GOPACKAGE}/howler.init.d")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
