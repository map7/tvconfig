#!/usr/bin/env ruby
#
# SiliconDust HDHomerun Network Dual Tuner
#

require File.expand_path(File.dirname(__FILE__) + '/../lib/general.rb')
include General

install "hdhomerun-config hdhomerun-config-gui vlc"

`hdhomerun_config_gui`
