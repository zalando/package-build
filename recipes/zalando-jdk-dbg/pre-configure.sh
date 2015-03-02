#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
LONGVERSION=${LONGVERSION/-/_}
VERSION=${LONGVERSION##*_}
TARGET="cache/jdk-7u${VERSION}-linux-x64.tar.gz"

[ -d cache ] || mkdir -p cache
[ -f $TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $TARGET http://download.oracle.com/otn-pub/java/jdk/7u${VERSION}-b13/jdk-7u${VERSION}-linux-x64.tar.gz
[ -d cache/jdk${LONGVERSION}/ ] || tar xf $TARGET -C cache/

[ -d tmp-javasrc ] || mkdir tmp-javasrc
[ -d tmp-rt ] || mkdir tmp-rt


if grep -qE 'Debian|Ubuntu' /etc/issue
then
	apt-get -y install unzip
fi

unzip -ou cache/jdk${LONGVERSION}/src.zip -d tmp-javasrc
find tmp-javasrc/ -name *.java > filelist.txt
cache/jdk${LONGVERSION}/bin/javac -J-Xms16m -J-Xmx1024m -sourcepath tmp-javasrc/ -cp cache/jdk${LONGVERSION}/jre/lib/rt.jar -d tmp-rt/ -g @filelist.txt
cache/jdk${LONGVERSION}/bin/jar cf0 rt_debug.jar -C tmp-rt .

[ -d cache/jdk${LONGVERSION}/jre/lib/endorsed ] || mkdir cache/jdk${LONGVERSION}/jre/lib/endorsed
mv rt_debug.jar cache/jdk${LONGVERSION}/jre/lib/endorsed

