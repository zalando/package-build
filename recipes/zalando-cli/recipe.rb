#!/bin/env ruby
# encoding: utf-8

class ZalandoCli < FPM::Cookery::Recipe
  description "Boilerplate code for CLI tools."

  name     "zalando-cli"
  version  "0.0.6"
  revision  201508031338
  arch      "all"

  homepage      "https://stash.zalando.net/projects/PYMODULES/repos/zalando-cli/browse"
  source        "https://stash.zalando.net/scm/pymodules/zalando-cli.git", :with => :git, :tag => "#{version}"
  maintainer    "Sören König <soeren.koenig@zalando.de>"

  build_depends   "python-setuptools"
  depends         "python-docopt"

  def build
    safesystem 'python setup.py build'
  end

  def install
      safesystem 'python setup.py install --root=../../tmp-dest --no-compile'
  end
end
