#!/bin/bash

## create DEB repo
# create a file /etc/apt/sources.list.d/zalando.list with following content:
# deb http://iftp.zalando.net/repo/debian   trusty   zalando OR
# deb http://iftp.zalando.net/repo/debian   precise  zalando etc.

basedir=/data/zalando/iftp.zalando.net/htdocs/repo/debian/
repositories=( trusty precise wheezy squeeze lenny )

for repository in ${repositories[@]}; do
   mkdir -p ${basedir}/pool/${repository}/zalando/binary-i386/
   mkdir -p ${basedir}/pool/${repository}/zalando/binary-amd64/
   mkdir -p ${basedir}/dists/${repository}

   find ${basedir}/dists/${repository} -type f -name Packages\* -exec rm {} \;

   echo -n "generating ${repository} .deb repo..."

## packages located on one unique location / reference in dists/DISTRIBUTIONNAME/ to this location
##################################################################################################
   cd ${basedir} || exit 1
   dpkg-scanpackages pool/${repository} /dev/null > /tmp/Packages 2> /dev/null
   cat /tmp/Packages | gzip > /tmp/Packages.gz
   cat /tmp/Packages | bzip2 > /tmp/Packages.bz2

   cp /tmp/Packages ${basedir}/dists/${repository}/
   ln ${basedir}/dists/${repository}/Packages ${basedir}/dists/${repository}/zalando/binary-amd64/Packages
   ln ${basedir}/dists/${repository}/Packages ${basedir}/dists/${repository}/zalando/binary-i386/Packages

   cp /tmp/Packages.gz ${basedir}/dists/${repository}/
   ln ${basedir}/dists/${repository}/Packages.gz ${basedir}/dists/${repository}/zalando/binary-amd64/Packages.gz
   ln ${basedir}/dists/${repository}/Packages.gz ${basedir}/dists/${repository}/zalando/binary-i386/Packages.gz

   cp /tmp/Packages.bz2 ${basedir}/dists/${repository}/
   ln ${basedir}/dists/${repository}/Packages.bz2 ${basedir}/dists/${repository}/zalando/binary-amd64/Packages.bz2
   ln ${basedir}/dists/${repository}/Packages.bz2 ${basedir}/dists/${repository}/zalando/binary-i386/Packages.bz2

   echo "Origin: Zalando-Repository" > ${basedir}/dists/${repository}/Release
   echo "Label: Zalando" >> ${basedir}/dists/${repository}/Release
   echo "Suite: ${repository} " >> ${basedir}/dists/${repository}/Release
   echo "Version: 5.0.4" >> ${basedir}/dists/${repository}/Release
   echo "Codename: ${repository}" >> ${basedir}/dists/${repository}/Release
   echo "Architectures: amd64" >> ${basedir}/dists/${repository}/Release
   echo "Components: Zalando" >> ${basedir}/dists/${repository}/Release
   echo "Description: Debian ${repository} 5.0.4 " >> ${basedir}/dists/${repository}/Release

   apt-ftparchive release dists/${repository}/ >> ${basedir}/dists/${repository}/Release

   rm -f dists/${repository}/Release.gpg

   echo "signit" | gpg --logger-fd 1 --keyring trustdb.gpg --secret-keyring trustdb.gpg --passphrase-fd 0 -a -b -s -q -u "Zalando Repository <sysop@zalando.de>" --batch -o dists/${repository}/Release.gpg dists/${repository}/Release

   find ${basedir}/dists/${repository}/zalando -type f -name Release -exec rm {} \;
   ln ${basedir}/dists/${repository}/Release dists/${repository}/zalando/binary-amd64/Release
   ln ${basedir}/dists/${repository}/Release dists/${repository}/zalando/binary-i386/Release

   echo "done."
done

## create RPM repo
# create a file /etc/yum.repos.d/zalando.repo with following content (section names must be uniqe):
# [zalando-base]
# name=Zalando-centos6.5 - Base
# baseurl=http://iftp.zalando.net/repo/centos/centos6.5/base/$basearch/
#
# [zalando-updates]
# name=Zalando-centos6.5 - Updates
# baseurl=http://iftp.zalando.net/repo/centos/centos6.5/updates/$basearch/
#
# [zalando-extras]
# name=Zalando-centos6.5 - Extras
# baseurl=http://iftp.zalando.net/repo/centos/centos6.5/extras/$basearch/

basedir=/data/zalando/iftp.zalando.net/htdocs/repo/centos/
releases=( centos6.5 )
sections=( base updates extras )
archs=( i386 x86_64 )

for release in ${releases[@]}
do
    echo -n "generating CentOS/RedHat ${release} .rpm repo..."
    for section in ${sections[@]}
    do
        for arch in ${archs[@]}
        do
            mkdir -p $basedir/${release}/${section}/${arch}/
            createrepo $basedir/${release}/${section}/${arch}/ &>/dev/null
        done
    done
    echo "done."
done

