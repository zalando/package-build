#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class MacaqueZmonAgg < FPM::Cookery::Recipe
  description "Macaque is a Zmon aggregator API, written in Go."
  GOPACKAGE = "github.com/zalando-incubator/macaque-zmon-agg"

  name      "macaque-zmon-agg"
  version   "1.1.0"
  revision  201512221610

  homepage      "https://github.com/zalando-incubator/macaque-zmon-agg"
  source        "https://github.com/zalando-incubator/macaque-zmon-agg.git", :with => :git, :tag => "#{version}"
  maintainer    "Sandor Szücs <sandor.szuecs@zalando.de>"

  build_depends   "golang-go git"

  def build
    # Set up directory structure and $GOPATH.
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    # Install dependencies.
    safesystem "go get github.com/tools/godep"
    safesystem "cd ${GOPATH}/src/#{GOPACKAGE} && ${GOPATH}/bin/godep restore"
    safesystem "go install #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/#{name}")
    (etc/"init.d/").install builddir("gobuild/src/#{GOPACKAGE}/scripts/macaque")
    (etc/"macaque/").install builddir("gobuild/src/#{GOPACKAGE}/config.yaml.sample")
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
