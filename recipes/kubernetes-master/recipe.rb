#!/bin/env ruby
# encoding: utf-8

class KubernetesMaster < FPM::Cookery::Recipe
  description "Container Cluster Manager from Google http://kubernetes.io"
  GOPACKAGE = "github.com/kubernetes/kubernetes"

  name      "zalando-kubernetes-master"
  version   "1.1.4"
  revision  201508271327

  homepage      "https://kubernetes.io/"
  source        "https://github.com/kubernetes/kubernetes/archive/v1.1.4.tar.gz"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go"

  def build
      make
  end

  def install
    etc("init").install_p(workdir("kube-controller-manager.conf.upstart"), "kube-controller-manager.conf")
    etc("init.d").install_p(workdir("kube-controller-manager_init.d"), "kube-controller-manager")
    etc("init").install_p(workdir("kube-apiserver.conf.upstart"), "kube-apiserver.conf")
    etc("init.d").install_p(workdir("kube-apiserver_init.d"), "kube-apiserver")
    etc("init").install_p(workdir("kube-scheduler.conf.upstart"), "kube-scheduler.conf")
    etc("init.d").install_p(workdir("kube-scheduler_init.d"), "kube-scheduler")
    bin.install builddir("kubernetes-1.1.4/_output/local/bin/linux/amd64/kube-controller-manager")
    bin.install builddir("kubernetes-1.1.4/_output/local/bin/linux/amd64/kube-apiserver")
    bin.install builddir("kubernetes-1.1.4/_output/local/bin/linux/amd64/kube-scheduler")
  end
end
