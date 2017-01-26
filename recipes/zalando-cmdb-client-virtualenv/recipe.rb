#!/bin/env ruby
# encoding: utf-8

class ZalandoCMDBClient < FPM::Cookery::VirtualenvRecipe
  description "Python client library for CMDB REST API."

  name     "zalando-cmdb-client"
  version  "1.0.20"
  revision  201511102030
  arch     "all"

  homepage      "https://github.bus.zalan.do/team-ghost/zalando-cmdb-client"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  virtualenv_install_location "/opt/"
  virtualenv_fix_name   false

end
