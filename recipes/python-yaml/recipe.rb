#!/bin/env ruby
# encoding: utf-8

class PythonYaml < FPM::Cookery::Recipe
  description "YAML parser and emitter for Python"

  name      "python-yaml"
  version   "3.11"
  revision  0
  arch      "all"

  homepage      "http://pyyaml.org/wiki/PyYAML"
  source        "http://pyyaml.org/download/pyyaml/PyYAML-#{version}.tar.gz"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends ["python-setuptools"]
  depends       ["python"]

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
