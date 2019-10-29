class ZalandoLibauthenKrb5Perl < FPM::Cookery::Recipe
  description 'Perl interface to Kerberos 5 API'

  name 'zalando-libauthen-krb5-perl'
  version '1.9.4'
  revision '1'

  source 'http://archive.ubuntu.com/ubuntu/pool/universe/liba/libauthen-krb5-perl/libauthen-krb5-perl_1.9.orig.tar.gz'
  sha256 'ead411cbf95648498c9b4acc90df353ec65c20f5f50cd4ea2811ff99c6f85fbd'

  build_depends 'perl', 'libkrb5-dev'
  depends 'perl', 'perlapi-5.22.1', 'libc6', 'libcomerr2', 'libk5crypto3', 'libkrb5-3'
    
  replaces 'libauthen-krb5-perl'

  def build
    Dir.glob("#{workdir('patches')}/*").each do |file|
      patch file, 1
    end

    safesystem 'perl Makefile.PL'

    make
  end

  def install
    make :install, 'DESTDIR' => destdir
  end
end
