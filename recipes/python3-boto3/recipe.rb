class Python3Boto3 < FPM::Cookery::Recipe
  description "Python interface to Amazon's Web Services"

  name     'python3-boto3'
  version  '0.0.10'
  revision 0
  homepage 'http://aws.amazon.com/sdk-for-python/'
  source   'https://github.com/boto/boto3.git', :with => :git, :tag => "#{version}"

  build_depends 'python-docutils'
  #depends       'libsqlite0', 'python-sqlite'

  def build
    safesystem 'apt-get install -y python3-setuptools'
    safesystem '/usr/bin/easy_install3 pip'
  end

  def install
    with_trueprefix do
        safesystem "/usr/local/bin/pip3 install boto3 --target #{destdir}/usr/local/lib/python3.2/dist-packages/"
    end
  end
end
