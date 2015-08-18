#!/bin/env ruby
# encoding: utf-8

class PythonDocopt < FPM::Cookery::PythonRecipe

  name      "docopt"
  version   "0.6.2"
  revision  0
  arch      "all"
  homepage  "http://docopt.org"

  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends ["python-setuptools"]
  depends       ["python"]
end
