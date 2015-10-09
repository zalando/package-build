#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
LONGVERSION=${LONGVERSION/-/_}
VERSION=${LONGVERSION##*_}
JDK_TARGET="cache/jdk-7u${VERSION}-linux-x64.tar.gz"
JCE_TARGET="cache/jce_policy-7.zip"

[ -d cache ] || mkdir -p cache
[ -f $JDK_TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $JDK_TARGET http://download.oracle.com/otn-pub/java/jdk/7u${VERSION}-b15/jdk-7u${VERSION}-linux-x64.tar.gz
[ -f $JCE_TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $JCE_TARGET http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip
unzip -o cache/jce_policy-7.zip -d cache/
