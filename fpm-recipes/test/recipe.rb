class Testscript < FPM::Cookery::Recipe
  description 'testscript'

  v = '0.0.1'
  name     'testscript'
  version  "0:#{v}"
  revision 0
  homepage 'http://golang.org/'
  sha256 'c368d2f246885e20ddabc4c418b78d6915e9d9a411b5d7b6897ade9bfca18e97'
  source "script.sh"

  def build
#    ENV['GOROOT_FINAL'] = '/usr/share/go'
  end

  def install
    #mkdir_p share
    #cp_r builddir('script.sh'), share('go')
    #bin.install 'script.sh'
    opt('scripts').install_p(workdir('script.sh'), 'hello')
  end
end