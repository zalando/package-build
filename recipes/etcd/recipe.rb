#!/bin/env ruby
# encoding: utf-8

class Etcd < FPM::Cookery::Recipe
  description "A distributed consistent key-value store for shared configuration and service discovery"
  GOPACKAGE = "github.com/coreos/etcd"

  name      "zalando-etcd"
  version   "2.1.1"
  revision  201507221106

  homepage      "https://github.com/coreos/etcd"
  source        "https://github.com/coreos/etcd.git", :with => :git
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
    # safesystem "go get -v #{GOPACKAGE}"
    # safesystem "go get -v #{GOPACKAGE}/etcdctl"
    safesystem "cd $GOPATH/src/github.com/coreos/etcd && ./build"
  end

  def install
    etc("init").install_p(workdir("etcd.conf.upstart"), "etcd.conf")
    etc("init.d").install_p(workdir("etcd_init.d"), "etcd")
    bin.install builddir("gobuild/src/github.com/coreos/etcd/bin/etcd")
    bin.install builddir("gobuild/src/github.com/coreos/etcd/bin/etcdctl")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
