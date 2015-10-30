class Golang < FPM::Cookery::Recipe
  description 'golang'

  name      'golang-go'
  version   '2:1.5.1'
  homepage  'http://golang.org/'
  source    "http://golang.org/dl/go1.5.1.linux-amd64.tar.gz"
  sha1      '46eecd290d8803887dec718c691cc243f2175fe0'

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
