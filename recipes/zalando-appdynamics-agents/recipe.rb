#!/bin/env ruby
# encoding: utf-8

class ZalandoAppdynamicsAgents < FPM::Cookery::Recipe
  description "Appdynamics agents bundle containing AppServerAgent and MachineAgent"

  version   "4.1.0.4"
  revision   4
  arch      "all"
  name      "zalando-appdynamics-agents"
  homepage  "http://www.appdynamics.com/"
  source    "cache/appdynamics.tgz"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section    "non-free/net"

  post_install "post-install"

  def build
  end

  def install
     root("/").install Dir["rootfs/*"]
  end

end
