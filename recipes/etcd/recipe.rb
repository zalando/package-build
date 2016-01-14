#!/bin/env ruby
# encoding: utf-8

class Etcd < FPM::Cookery::Recipe
  description "A distributed consistent key-value store for shared configuration and service discovery"
  GOPACKAGE = "github.com/coreos/etcd"
  TAG = "v2.2.4"

  name      "zalando-etcd"
  version   "2.2.4"
  revision  201512161414

  homepage      "https://github.com/coreos/etcd"
  source        "https://github.com/coreos/etcd.git", :with => :git, :extract => :clone, :tag => "#{TAG}"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go git"

  def build
    safesystem "./build"
  end

  def install
    etc("init").install_p(workdir("etcd.conf.upstart"), "etcd.conf")
    etc("init.d").install_p(workdir("etcd_init.d"), "etcd")
    bin.install builddir("etcd-tag-#{TAG}/bin/etcd")
    bin.install builddir("etcd-tag-#{TAG}/bin/etcdctl")
  end
end
