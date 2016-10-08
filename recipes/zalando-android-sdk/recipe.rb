#!/bin/env ruby
# encoding: utf-8

class ZalandoAndroidSDK < FPM::Cookery::Recipe
  description "Software development kit for Android platform"

  version   "24.4.1"
  revision   4
  arch      "all"
  name      "zalando-android-sdk"
  homepage  "https://developer.android.com/studio/index.html"
  source    "cache/android-sdk_r#{version}-linux.tgz"
  sha1      "725bb360f0f7d04eaccff5a2d57abdd49061326d"

  maintainer "Sören König <soeren.koenig@zalando.de>"
  section    "devel"
  depends    "zalando-jdk8-1.8.0-66", "lib32z1", " libc6:i386", "libncurses5:i386", "libstdc++6:i386"

  post_install 'postinst'
  config_files '/etc/profile.d/android.sh'

  def build
      safesystem "find tools/ -maxdepth 1 -type f  -exec chmod +x {} +"
  end

  def install
     root("/server/android-sdk/").install Dir["*"]
     etc('profile.d').install workdir('android.sh'), 'android.sh'
  end

end
