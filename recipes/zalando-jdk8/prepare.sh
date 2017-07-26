#!/bin/bash
set -e

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
LONGVERSION=${LONGVERSION/-/_}
VERSION=${LONGVERSION##*_}
JDK_TARGET="cache/jdk-8u${VERSION}-linux-x64.tar.gz"
JCE_TARGET="cache/jce_policy-8.zip"

# Oracle keeps changing their download links, see this thread: https://stackoverflow.com/questions/10268583/downloading-java-jdk-on-linux-via-wget-is-shown-license-page-instead#
case ${LONGVERSION} in
    '1.8.0_131')
        JDK_SOURCE='http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz'
        ;;
    *)
        echo >&2 "there is no JDK_SOURCE configured for ${LONGVERSION}"
        exit 1
        ;;
esac

[ -d cache ] || mkdir -p cache
[ -f $JDK_TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $JDK_TARGET $JDK_SOURCE
[ -f $JCE_TARGET ] || curl -jkLH 'Cookie: oraclelicense=accept-securebackup-cookie' --progress-bar -o $JCE_TARGET http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
unzip -o cache/jce_policy-8.zip -d cache/
