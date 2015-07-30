#!/bin/env ruby
# encoding: utf-8

class BaboonStatus < FPM::Cookery::Recipe
  description "Status page for baboon-proxy."

  name     "baboon-status"
  version  "0.0.6"
  revision  201507301749
  arch     "all"

  homepage      "https://stash.zalando.net/projects/system/repos/baboon-status/browse"
  source        "https://stash.zalando.net/scm/system/baboon-status.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  post_install  "post-install"

  build_depends "python-setuptools"

  platforms [:ubuntu, :debian] do
    depends     "requests >= 2.5.2", "zalando-cli"
  end

  platforms [:centos] do
    depends     "requests >= 2.5.2", "zalando-cli"
  end

  def build
    safesystem "python setup.py build"
  end

  def install
      safesystem "python setup.py install --root=../../tmp-dest --no-compile"
      (etc/"cron.d/").install_p(workdir/"crontab", "zalando-baboon-status")
  end
end
