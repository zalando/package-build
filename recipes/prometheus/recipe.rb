#!/bin/env ruby
# encoding: utf-8

class Prometheus < FPM::Cookery::Recipe
  description "The Prometheus monitoring system and time series database."
  GOPACKAGE = "github.com/prometheus/prometheus"
  TAG = "0.16.1"

  name      "zalando-prometheus"
  version   "0.16.1"
  revision  201601141030

  homepage      "http://prometheus.io/"
  source        "https://github.com/prometheus/prometheus.git", :with => :git, :extract => :clone, :tag => "#{TAG}"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "cp -r . $GOPATH/src/#{GOPACKAGE}"
    safesystem "export PATH=$PATH:$GOPATH/bin; cd $GOPATH/src/#{GOPACKAGE} && make build"
  end

  def install
    etc("default").install_p(workdir("prometheus.default"), "prometheus")
    etc("init").install_p(workdir("prometheus.conf.upstart"), "prometheus.conf")
    bin.install builddir("gobuild/src/#{GOPACKAGE}/prometheus")
    bin.install builddir("gobuild/src/#{GOPACKAGE}/promtool")
  end
end
