#!/bin/env ruby
# encoding: utf-8

class Consul < FPM::Cookery::Recipe
  description "A tool for managing secrets, written in Go."
  GOPACKAGE = "zalando.de/system/vault"

  name      "zalando-vault"
  version   "0.1.3"
  revision  201506101727

  homepage      "http://vaultproject.io/"
  source        "https://github.com/hashicorp/vault.git", :with => :git
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
  end

  def install
    etc("init").install_p(workdir("vault.conf.upstart"), "vault.conf")
    etc("vault").install_p(workdir("vault_config.hcl"), "config.hcl")
    bin.install builddir("gobuild/bin/vault")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
