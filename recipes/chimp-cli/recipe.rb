#!/bin/env ruby
# encoding: utf-8

class ChimpCli < FPM::Cookery::Recipe
  description "Command Line Interface for Chimp."
  GOPACKAGE = "github.com/zalando-techmonkeys/chimp"

  name      "chimp-cli"
  version   "0.0.1"
  revision  201508251650

  homepage      "https://stash.zalando.net/projects/SYSTEM/repos/chimp/browse/"
  source        "https://stash.zalando.net/scm/system/chimp.git", :with => :git, :branch => 'master'
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git mercurial"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")
    safesystem "go env"

    safesystem "go get github.com/tools/godep"
    safesystem "cd ${GOPATH}/src/github.com/zalando-techmonkeys/chimp/ && ${GOPATH}/bin/godep restore"
    safesystem "go install #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/chimp-cli")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
