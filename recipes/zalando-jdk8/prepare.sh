#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
LONGVERSION=${LONGVERSION/-/_}
VERSION=${LONGVERSION##*_}
TARGET="cache/jdk-8u${VERSION}-linux-x64.tar.gz"

[ -d cache ] || mkdir -p cache
[ -f $TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $TARGET http://download.oracle.com/otn-pub/java/jdk/8u${VERSION}-b16/jdk-8u${VERSION}-linux-x64.tar.gz
