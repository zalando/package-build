#!/bin/env ruby
# encoding: utf-8

class ZalandoZcloud < FPM::Cookery::VirtualenvRecipe
  description "Package containing CLI, agent and additional scripts for installing nodes via zCloud"

  name     "zalando-zcloud"
  version  "0.2.8"
  revision  201511091736
  arch     "all"

  homepage      "https://stash.zalando.net/projects/PYMODULES/repos/zalando-zcloud/browse"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"

  virtualenv_fix_name false
  virtualenv_install_location "/opt/"

end
