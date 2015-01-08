
SRC=tmp-build
PKG=pkg

patch:
	echo "please apply patchfile to the source"

# $ dpkg -L nagios-nrpe-plugin              /.
# /usr
# /usr/share
# /usr/share/doc
# /usr/share/doc/nagios-nrpe-plugin
# /usr/share/doc/nagios-nrpe-plugin/NEWS.Debian.gz
# /usr/share/doc/nagios-nrpe-plugin/changelog.Debian.gz
# /usr/share/doc/nagios-nrpe-plugin/copyright
# /usr/lib
# /usr/lib/nagios
# /usr/lib/nagios/plugins
# /usr/lib/nagios/plugins/check_nrpe
# /etc
# /etc/nagios-plugins
# /etc/nagios-plugins/config
# /etc/nagios-plugins/config/check_nrpe.cfg
deb:
	dpkg -l nagios3-common >/dev/null || sudo apt-get install -y --quiet nagios3-common
	make -C $(SRC)
	mkdir -p $(PKG)/usr/share/doc/nagios-nrpe-plugin
	cp -a $(SRC)/debian.plugin/* $(PKG)/usr/share/doc/nagios-nrpe-plugin/
	mkdir -p $(PKG)/usr/lib/nagios/plugins
	cp -a $(SRC)/src/check_nrpe $(PKG)/usr/lib/nagios/plugins/
	mkdir -p $(PKG)/etc/nagios-plugins/config
	cp -a $(SRC)/etc/nagios-plugins/config/check_nrpe.cfg $(PKG)/etc/nagios-plugins/config/
	fpm -f -n zalando-nagios-nrpe-plugin \
		--deb-user nagios --deb-group nagios \
		--deb-build-depends nagios3-common \
		--replaces nagios-nrpe-plugin \
		--prefix / \
		-C ${PKG}/ \
		-s dir -t deb .

debdev:
	sudo apt-get install -y --quiet nagios3-common openssl-dev

# [vagrant@vagrant-centos65 ~]$ rpm -ql nagios-plugins-nrpe
# /usr/lib64/nagios/plugins/check_nrpe
# /usr/share/doc/nagios-plugins-nrpe-2.15
# /usr/share/doc/nagios-plugins-nrpe-2.15/Changelog
# /usr/share/doc/nagios-plugins-nrpe-2.15/LEGAL
# /usr/share/doc/nagios-plugins-nrpe-2.15/README
rpm:
	rpm -ql nagios-common >/dev/null || sudo yum install -y nagios-common
	rpm -ql openssl-devel >/dev/null || sudo yum install -y openssl-devel
	make -C $(SRC)
	mkdir -p $(PKG)/usr/share/doc/nagios-plugins-nrpe-2.15
	cp -a $(SRC)/centos.plugin/* $(PKG)/usr/share/doc/nagios-plugins-nrpe-2.15/
	mkdir -p $(PKG)/usr/lib64/nagios/plugins
	cp -a $(SRC)/src/check_nrpe $(PKG)/usr/lib64/nagios/plugins/
	fpm -f -n zalando-nagios-nrpe-plugin \
		--rpm-user nagios --rpm-group nagios \
		--depends nagios-common \
		--replaces nagios-plugins-nrpe \
		--prefix / \
		-C ${PKG}/ \
		-s dir -t rpm .

rpmdev:
	sudo yum install nagios-common openssl-devel

clean:
	rm -rf $(PKG)
	make -C $(SRC) clean

# dpkg -c zalando-nagios-nrpe-plugin_1.0_amd64.deb
# rpm -q -filesbypkg -p zalando-nrpe-1.0-1.x86_64.rpm
