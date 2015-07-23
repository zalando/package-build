#!/bin/env ruby
# encoding: utf-8

class Kubectl < FPM::Cookery::Recipe
  description "Client for managing Kubernetes http://kubernetes.io"
  GOPACKAGE = "github.com/GoogleCloudPlatform/kubernetes"

  name      "zalando-kubectl"
  version   "1.0.1"
  revision  201507231048

  homepage      "https://kubernetes.io/"
  source        "https://github.com/GoogleCloudPlatform/kubernetes/archive/v1.0.1.tar.gz"
  maintainer    "Markus Wyrsch <markus.wyrsch@zalando.de>"

  build_depends   "golang-go"

  def build
      make
  end

  def install
    bin.install builddir("kubernetes-1.0.1/_output/local/bin/linux/amd64/kubectl")
  end
end
