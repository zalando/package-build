#!/bin/env ruby
# encoding: utf-8

class PythonRequests < FPM::Cookery::PythonRecipe

  name      "requests"
  version   "2.7.0"
  revision  0
  arch      "all"
  homepage  "http://python-requests.org"

  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends ["python-setuptools"]
  depends        ["python"]
end
