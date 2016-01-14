#!/bin/env ruby
# encoding: utf-8

class Kubelet < FPM::Cookery::Recipe
  description "Container Cluster Manager from Google http://kubernetes.io"
  GOPACKAGE = "github.com/kubernetes/kubernetes"

  name      "zalando-kubelet"
  version   "1.1.4"
  revision  201508271309

  homepage      "https://kubernetes.io/"
  source        "https://github.com/kubernetes/kubernetes/archive/v1.1.4.tar.gz"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go"

  def build
      make
  end

  def install
    etc("init").install_p(workdir("kubelet.conf.upstart"), "kubelet.conf")
    etc("init.d").install_p(workdir("kubelet_init.d"), "kubelet")
    bin.install builddir("kubernetes-1.1.4/_output/local/bin/linux/amd64/kubelet")
  end
end
