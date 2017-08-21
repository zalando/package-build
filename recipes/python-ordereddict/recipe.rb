#!/bin/env ruby
# encoding: utf-8

class PythonOrderedDict < FPM::Cookery::PythonRecipe

  name      "ordereddict"
  version   "1.1"
  revision  0
  arch      "all"
  homepage  "https://code.activestate.com/recipes/576693/"

  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends ["python-setuptools"]
  depends       ["python"]
end
