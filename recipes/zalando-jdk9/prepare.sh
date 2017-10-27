#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
VERSION=${LONGVERSION%%+*}
JDK_TARGET="cache/jdk-${LONGVERSION}_linux-x64_bin.tar.gz"
JDK_SOURCE="http://download.oracle.com/otn-pub/java/jdk/${LONGVERSION}/jdk-${VERSION}_linux-x64_bin.tar.gz"

[ -d cache ] || mkdir -p cache
[ -f $JDK_TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $JDK_TARGET $JDK_SOURCE

