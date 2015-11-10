#!/bin/env ruby
# encoding: utf-8

class ConsulTemplate < FPM::Cookery::Recipe
  description "Generic template rendering and notifications with Consul."
  GOPACKAGE = "github.com/hashicorp/consul-template"

  name      "zalando-consul-template"
  version   "0.10.0"
  revision  201506242000

  homepage      "https://github.com/hashicorp/consul-template/"
  source        "https://github.com/hashicorp/consul-template.git", :with => :git
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    # ugly hack, but we need the `develop` branch of github.com/gin-gonic/gin/
    safesystem "go get -v github.com/gin-gonic/gin/"
    safesystem "cd $GOPATH/src/github.com/gin-gonic/gin/ && git checkout develop"
    safesystem "go get -v #{GOPACKAGE}"
  end

  def install
    etc("consul-template").install_p(workdir("consul-template_config.hcl"), "config.hcl")
    bin.install builddir("gobuild/bin/consul-template")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
