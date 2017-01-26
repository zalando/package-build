#!/bin/env ruby
# encoding: utf-8

class NagiosPluginsOptionalLinux < FPM::Cookery::Recipe
  description 'Nagios and NRPE Plugins for Linux monitoring'

  version  "0.0.1"
  revision  1
  arch     "all"
  name     "nagios-plugins-optional-linux"

  homepage   "https://github.bus.zalan.do/system/nagios-plugins-optional-linux"
  source     "https://github.bus.zalan.do/system/nagios-plugins-optional-linux.git", :with => :git
  maintainer "Sören König <soeren.koenig@zalando.de>"

  section    "universe/net"
  depends    "nagios-plugins-basic >= 1.4.0", "nagios-snmp-plugins", "original-awk | gawk", "coreutils", "bash", "bc", "grep", "snmp", "snmpd", "sysstat", "sed", "perl-base", "libnet-snmp-perl", "iputils-ping", "iproute"

  pre_install    "preinst"
  post_install   "postinst"
  post_uninstall "postrm"

  def build
  end

  def install
    etc("nagios/ngraph.d/optional").mkdir
    etc("/etc/nagios-plugins/config").mkdir
    prefix('share/nagios-plugins/templates-optional').install Dir["usr/share/nagios-plugins/templates-optional/*"]
    prefix('lib/nagios/plugins').install Dir["usr/lib/nagios/plugins/*"]
  end
end
