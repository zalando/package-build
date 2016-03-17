#!/bin/env ruby
# encoding: utf-8

# THIS SHOULD NOT BE USED ANYMORE, BECAUSE THE BINARIES FOR THIS PROJECT ARE NOW
# COMPILED AND DISTRIBUTED VIA CI JOBS.

class Chimp < FPM::Cookery::Recipe
  description "Command Line Interface for Chimp."
  GOPACKAGE = "github.com/zalando-techmonkeys/chimp"

  name      "chimp"
  version   "v0.4.5"
  revision  201510061821

  homepage      "https://stash.zalando.net/projects/SYSTEM/repos/chimp/browse/"
  source        "https://stash.zalando.net/scm/system/chimp.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "golang-go git mercurial"

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
