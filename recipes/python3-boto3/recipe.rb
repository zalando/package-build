#!/bin/env ruby
# encoding: utf-8

class Python3Boto3 < FPM::Cookery::Recipe
  # This creates the python3-boto3 package with all it's dependencies.
  # This is a bit hacky: boto3 is installed via pip3 into the destdir,
  # which is going to be packaged by fpm afterwards.
  description "Python interface to Amazon's Web Services"

  name     "python3-boto3"
  version  "1.1.0"
  revision 0
  arch      "all"
  homepage "http://aws.amazon.com/sdk-for-python/"
  source   "https://github.com/boto/boto3.git", :with => :git, :tag => "#{version}"

  maintainer    "Sören König <soeren.koenig@zalando.de>"
  build_depends "python3-setuptools"
  depends 	    "python3"

  def build
    safesystem '/usr/bin/easy_install3 pip'
  end

  def install
    with_trueprefix do
        safesystem "/usr/local/bin/pip3 install #{cachedir}/boto3.git --target #{destdir}/usr/local/lib/python3.2/dist-packages/"
    end
  end
end
