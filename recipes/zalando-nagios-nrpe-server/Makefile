
SRC=tmp-build
PKG=pkg

patch:
	echo "please apply patchfile to the source"

# $ dpkg -L nagios-nrpe-server
deb:
	dpkg -l nagios3-common >/dev/null || sudo apt-get install -y --quiet nagios3-common
	make -C $(SRC)
	mkdir -p $(PKG)/usr/share/man/man8
	cp -a $(SRC)/debian.nrpe/man/* $(PKG)/usr/share/man/man8/
	mkdir -p $(PKG)/usr/share/doc/nagios-nrpe-server
	cp -a $(SRC)/debian.nrpe/doc/* $(PKG)/usr/share/doc/nagios-nrpe-server/
	mkdir -p $(PKG)/usr/sbin
	cp -a $(SRC)/src/nrpe $(PKG)/usr/sbin/
	mkdir -p $(PKG)/etc/init.d
	cp -a $(SRC)/debian.nrpe/etc/init.d/nagios-nrpe-server $(PKG)/etc/init.d/
	mkdir -p $(PKG)/etc/nagios/nrpe.d
	cp -a $(SRC)/debian.nrpe/etc/nagios/nrpe_local.cfg $(PKG)/etc/nagios/
	cp -a $(SRC)/debian.nrpe/etc/nagios/nrpe.cfg $(PKG)/etc/nagios/
	mkdir -p $(PKG)/etc/default
	cp -a $(SRC)/debian.nrpe/etc/default/nagios-nrpe-server $(PKG)/etc/default/
	fpm -f -n zalando-nagios-nrpe-server \
		--deb-user nagios --deb-group nagios \
		--deb-build-depends nagios3-common \
		--replaces nagios-nrpe-server \
		--prefix / \
		-C ${PKG}/ \
		-s dir -t deb .

# $ rpm -ql nrpe
rpm:
	rpm -ql nagios-common >/dev/null || sudo yum install -y nagios-common
	rpm -ql openssl-devel >/dev/null || sudo yum install -y openssl-devel
	make -C $(SRC)
	mkdir -p $(PKG)/etc/nagios
	cp -a $(SRC)/centos.nrpe/etc/nagios/nrpe.cfg $(PKG)/etc/nagios/
	mkdir -p $(PKG)/etc/nrpe.d
	mkdir -p $(PKG)/etc/rc.d/init.d
	cp -a $(SRC)/centos.nrpe/etc/rc.d/init.d/nrpe $(PKG)/etc/rc.d/init.d/
	mkdir -p $(PKG)/etc/sysconfig/
	cp -a $(SRC)/centos.nrpe/etc/sysconfig/nrpe $(PKG)/etc/sysconfig/
	mkdir -p $(PKG)/usr/sbin
	cp -a $(SRC)/src/nrpe $(PKG)/usr/sbin/
	mkdir -p $(PKG)/usr/share/doc/nrpe-2.15
	cp -a $(SRC)/centos.nrpe/doc/* $(PKG)/usr/share/doc/nrpe-2.15/
	mkdir -p $(PKG)/var/run/nrpe
	fpm -f -n zalando-nrpe \
		--rpm-user nagios --rpm-group nagios \
		--depends nagios-common \
		--replaces nrpe \
		--prefix / \
		-C ${PKG}/ \
		-s dir -t rpm .

rpmdev:
	sudo yum install openssl-devel

clean:
	rm -rf $(PKG)
	make -C $(SRC) clean
