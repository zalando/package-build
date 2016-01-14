class Golang < FPM::Cookery::Recipe
  description 'golang'

  name      'golang-go'
  version   '1.5.3'
  homepage  'http://golang.org/'
  source    "http://golang.org/dl/go#{version}.linux-amd64.tar.gz"
  sha256    '43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53'

  config_files '/etc/profile.d/go.sh'

  conflicts 'golang', 'golang-go', 'golang-src', 'golang-doc'
  replaces 'golang', 'golang-go', 'golang-src', 'golang-doc'

  def build
  end

  def install
    mkdir_p share
    cp_r builddir('go'), share('go')

    etc('profile.d').install workdir('go.profile'), 'go.sh'
  end
end
