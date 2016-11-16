#!/bin/env ruby
# encoding: utf-8

class PrometheusNodeExporter < FPM::Cookery::Recipe
  description "Prometheus exporter for machine metrics, written in Go with pluggable metric collectors."

  version   "0.12.0"
  revision   0
  name      "prometheus-node-exporter"
  homepage  "https://github.com/prometheus/node_exporter"
  source    "https://github.com/prometheus/node_exporter/releases/download/#{version}/node_exporter-#{version}.linux-amd64.tar.gz"
  sha256    "d48de5b89dac04aca751177afaa9b0919e5b3d389364d40160babc00d63aac7b"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section    "non-free/net"

  def build
  end

  def install
    bin.install Dir["node_exporter"]
    etc("init.d").install_p(workdir("node_exporter.init.d"), "node_exporter")
  end

end
