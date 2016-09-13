#!/bin/bash
set -e
set -x

# download resources
ANDROID_SDK_VERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
TARBALL=android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz
[ -f cache/"${TARBALL}" ] || curl -L --progress-bar -o cache/"${TARBALL}" https://dl.google.com/android/${TARBALL}
