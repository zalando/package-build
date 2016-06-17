class NagiosNRPEServer < FPM::Cookery::Recipe
  description 'Nagios Remote Plugin Executor'

  version     '2.15'
  revision    '2'
  name        'nagios-nrpe-server'

  homepage    'http://nagiosplugins.org/'
  source      "https://launchpad.net/ubuntu/+archive/primary/+files/nagios-nrpe_#{version}.orig.tar.gz"
  sha256      '66383b7d367de25ba031d37762d83e2b55de010c573009c6f58270b137131072'
  maintainer  'Sören König <soeren.koenig@zalando.de>'

  license     'Apache 2'
  section     'monitoring'

  depends       'nagios-plugins'
  build_depends 'gcc', 'make', 'libssl-dev'


  def build
    patch(workdir("nagios-nrpe_2.15-1ubuntu1.diff"), 1)

    configure :prefix => prefix

    make
    # this creates user & group "nagios", `make install` would fail, when they not exist
    safesystem('bash debian/nagios-nrpe-server.preinst install')
    safesystem('chmod +x debian/rules')
    safesystem('debian/rules binary')
  end

  def install
    make :install, 'DESTDIR' => destdir
    etc.install Dir['debian/nagios-nrpe-server/etc/*']
    doc.install Dir['debian/nagios-nrpe-server/usr/share/doc/*']
    man.install Dir['debian/nagios-nrpe-server/usr/share/man/*']

  end

  post_install
end
