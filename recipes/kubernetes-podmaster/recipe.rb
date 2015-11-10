#!/bin/env ruby
# encoding: utf-8

class Podmaster < FPM::Cookery::Recipe
  description "The podmaster binary for Kubernetes' HA."
  GOPACKAGE = "github.com/zalando-techmonkeys/kubernetes-podmaster"

  name      "zalando-podmaster"
  version   "0.0.1"
  revision  201508281256

  homepage      "https://github.com/zalando-techmonkeys/kubernetes-podmaster"
  source        "https://github.com/zalando-techmonkeys/kubernetes-podmaster.git", :with => :git
  maintainer    "Raffaele Di Fazio <raffaele.di.fazio@zalando.de>"

  build_depends   "git"

  def build
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")
    safesystem "go get github.com/coreos/go-etcd/etcd"
    safesystem "go get github.com/golang/glog"
    safesystem "go get github.com/spf13/pflag"
    safesystem "go get k8s.io/kubernetes/pkg/storage/etcd"
    safesystem "cd ${GOPATH}/src/github.com/zalando-techmonkeys/kubernetes-podmaster/"
    safesystem "go install #{GOPACKAGE}"
  end

  def install
    etc("default").install_p(workdir("kubernetes-podmaster.default"), "kubernetes-podmaster")
    etc("init").install_p(workdir("kubernetes-podmaster.conf.upstart"), "kubernetes-podmaster.conf")
    etc("init.d").install_p(workdir("kubernetes-podmaster.init.d"), "kubernetes-podmaster")
    bin.install builddir("gobuild/bin/kubernetes-podmaster")
    rm_rf "#{builddir}/gobuild/pkg", :verbose => true
    rm_rf "#{builddir}/gobuild/bin", :verbose => true
  end
end
