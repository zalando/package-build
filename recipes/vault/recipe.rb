#!/bin/env ruby
# encoding: utf-8

class Vault < FPM::Cookery::Recipe
  description "A tool for managing secrets, written in Go."
  GOPACKAGE = "github.com/hashicorp/vault"
  TAG = "v0.5.0"

  name      "zalando-vault"
  version   "0.5.0"
  revision  201602111350

  homepage      "http://vaultproject.io/"
  source        "https://github.com/hashicorp/vault.git", :with => :git, :extract => :clone, :tag => "#{TAG}"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir

    ENV["GOPATH"] = builddir("gobuild/")
    ENV["GO15VENDOREXPERIMENT"] = "0"

    safesystem "cp -r . $GOPATH/src/#{GOPACKAGE}"
    safesystem "export PATH=$PATH:$GOPATH/bin; cd $GOPATH/src/#{GOPACKAGE} && make bootstrap && make dev"
  end

  def install
    etc("init").install_p(workdir("vault.conf.upstart"), "vault.conf")
    etc("vault").install_p(workdir("vault_config.hcl"), "config.hcl")
    bin.install builddir("gobuild/bin/vault")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
