#!/bin/env ruby
# encoding: utf-8

class Consul < FPM::Cookery::Recipe
  description "Service discovery and configuration with dc awareness, written in Go."
  GOPACKAGE = "zalando.de/system/consul"

  name      "zalando-consul"
  version   "0.5.1"
  revision  201505181736

  homepage      "http://www.consul.io/"
  source        "https://github.com/hashicorp/consul.git", :with => :git
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "go version"
    safesystem "go env"
    # ugly hack, but we need the `develop` branch of github.com/gin-gonic/gin/
    safesystem "go get -v github.com/gin-gonic/gin/"
    safesystem "cd $GOPATH/src/github.com/gin-gonic/gin/ && git checkout develop"
    safesystem "go get -v #{GOPACKAGE}"
    safesystem "cd $GOPATH/src/#{GOPACKAGE}/ui && gem install bundler && bundle && make dist"
  end

  def install
    var("lib/consul-ui").install builddir("gobuild/src/#{GOPACKAGE}/ui/dist/index.html")
    var("lib/consul-ui").install builddir("gobuild/src/#{GOPACKAGE}/ui/dist/static/")
    etc("default").install_p(workdir("consul.default"), "consul")
    etc("init").install_p(workdir("consul.conf.upstart"), "consul.conf")
    # etc('init.d').install_p(workdir('consul.init.d'), 'consul')
    bin.install builddir("gobuild/bin/consul")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
