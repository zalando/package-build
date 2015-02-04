#!/bin/bash

VERSION=$(grep -m 1 version recipe.rb)
VERSION=${VERSION##*-}
VERSION=${VERSION/\"/}
TARGET="cache/jdk-7u${VERSION}-linux-x64.tar.gz"

[ -d cache ] || mkdir -p cache
[ -f $TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $TARGET http://download.oracle.com/otn-pub/java/jdk/7u${VERSION}-b13/jdk-7u${VERSION}-linux-x64.tar.gz
