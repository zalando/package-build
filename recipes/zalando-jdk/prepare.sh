#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
LONGVERSION=${LONGVERSION/-/_}
VERSION=${LONGVERSION##*_}
TARGET="cache/jdk-7u${VERSION}-linux-x64.tar.gz"

[ -d cache ] || mkdir -p cache
[ -f $TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $TARGET http://download.oracle.com/otn-pub/java/jdk/7u${VERSION}-b15/jdk-7u${VERSION}-linux-x64.tar.gz
