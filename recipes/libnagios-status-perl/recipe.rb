#!/bin/env ruby
# encoding: utf-8
# NOTE: This recipe has only been tested with ubuntu16.04 ("Xenial")

class LibNagiosStatusPerl < FPM::Cookery::Recipe
  description 'Perl extension for Nagios Status'

  version  "0.03.471"
  revision  1
  arch     "all"
  name     "libnagios-status-perl"

  homepage   "https://stash.zalando.net/projects/SYSTEM/repos/libnagios-status-perl/browse"
  source     "https://stash.zalando.net/scm/system/libnagios-status-perl.git", :with => :git
  maintainer "Matthias Kerk <matthias.kerk@zalando.de>"

  section    "perl"
  depends    "perl"

  def build
      safesystem "perl Makefile.PL PREFIX=usr/"
      make
      make :test
      make :install
  end

  def install
    prefix().install Dir["usr/*"]
  end
end
