#!/bin/env ruby
# encoding: utf-8

class Chimp < FPM::Cookery::Recipe
  description "Command Line Interface for Chimp."
  GOPACKAGE = "github.com/zalando-techmonkeys/chimp"

  name      "chimp"
  version   "v0.2.1"
  revision  201510011630

  homepage      "https://stash.zalando.net/projects/SYSTEM/repos/chimp/browse/"
  source        "https://stash.zalando.net/scm/system/chimp.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git mercurial"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "go get github.com/tools/godep"
    safesystem "cd ${GOPATH}/src/#{GOPACKAGE} && ${GOPATH}/bin/godep restore"
    safesystem "go install #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/chimp")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
