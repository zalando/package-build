#!/bin/env ruby
# encoding: utf-8

class Consul < FPM::Cookery::Recipe
  description "Service discovery and configuration with dc awareness, written in Go."
  GOPACKAGE = "github.com/hashicorp/consul"
  TAG = "v0.6.0"

  name      "zalando-consul"
  version   "0.6.0"
  revision  201601141144

  homepage      "http://www.consul.io/"
  source        "https://github.com/hashicorp/consul.git", :with => :git, :extract => :clone, :tag => "#{TAG}"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    safesystem "cp -r . $GOPATH/src/#{GOPACKAGE}"
    safesystem "export PATH=$PATH:$GOPATH/bin; cd $GOPATH/src/#{GOPACKAGE} && make dev"
    safesystem "cd $GOPATH/src/#{GOPACKAGE}/ui && gem install bundler && bundle && make dist"
  end

  def install
    var("lib/consul-ui").install builddir("gobuild/src/#{GOPACKAGE}/pkg/web_ui/index.html")
    var("lib/consul-ui").install builddir("gobuild/src/#{GOPACKAGE}/pkg/web_ui/static/")
    etc("default").install_p(workdir("consul.default"), "consul")
    etc("init").install_p(workdir("consul.conf.upstart"), "consul.conf")
    bin.install builddir("gobuild/bin/consul")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
