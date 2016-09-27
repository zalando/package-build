#!/bin/env ruby
# encoding: utf-8

class ZalandoSSHAuthorizedKeys < FPM::Cookery::Recipe
  description 'Fetch keys from LDAP for ssh pubkey authentication in real time'
  GOPACKAGE = 'github.bus.zalan.do/nobody/ssh-authorized-keys'

  name      'ssh-authorized-keys'
  version   '0.0.1'
  revision  201609271645

  homepage      'https://github.bus.zalan.do/nobody/ssh-authorized-keys'
  source        'git@github.bus.zalan.do:nobody/ssh-authorized-keys.git', :with => :git
  maintainer    'Sören König <soeren.koenig@zalando.de>'

  build_depends   'golang-go git'
  config_files    '/etc/ssh/ssh-authorized-keys.conf'

  def build
    # Set up directory structure and $GOPATH.
    pkgdir = builddir("gobuild/src/#{GOPACKAGE}")
    mkdir_p pkgdir
    cp_r Dir["*"], pkgdir

    ENV["GOPATH"] = builddir("gobuild/")

    # Install dependencies.
    safesystem "go get gopkg.in/ldap.v2"
    safesystem "go install #{GOPACKAGE}/..."
  end

  def install
    bin.install builddir("gobuild/bin/#{name}")
    etc('ssh').install builddir("gobuild/src/#{GOPACKAGE}/ssh-authorized-keys.conf")
  end

  def after_install
    # For allowing more than one successive builds, there has some cleanup to be done.
    # If the build cookie is still existing on the second run, fpm-cook will stop and
    # not build the binary again.
    package_name = "#{name}-#{version}"
    build_cookie_name = (builddir/".build-cookie-#{package_name.gsub(/[^\w]/,'_')}").to_s
    rm_rf "#{build_cookie_name}", :verbose => true
  end
end
