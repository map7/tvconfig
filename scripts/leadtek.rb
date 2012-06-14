#!/usr/bin/env ruby

require File.expand_path(File.dirname(__FILE__) + '/../lib/general.rb')
include General

MYTHTV_DIR = "#{ENV['HOME']}/.mythtv"
CHANNELS_CONF = "#{MYTHTV_DIR}/channels.conf"
LEADTEK_INIT = "/etc/init.d/leadtek"

# Make the config dir if it doesn't exist
Dir.mkdir MYTHTV_DIR unless File.exist?(MYTHTV_DIR)

puts "\nInstall required tools..."
install("build-essential lirc")

puts "\nScanning leadtek DVT2000DS card for Melbourne\n"
unless File.exists?("#{CHANNELS_CONF}") then
  install("dvb-apps")
  `sudo service mythtv-backend stop`
  sleep 5
  `scan /usr/share/dvb/dvb-t/au-Melbourne -o zap -a 0 | tee CHANNELS_CONF`
  `sudo service mythtv-backend start`
end

puts "\nFix for second tuner missing"
unless File.exists?("#{LEADTEK_INIT}") then
  File.open(LEADTEK_INIT, 'w') do |f|
    f.write <<-eos
#!/bin/bash
# Turn off USB power management to keep both DVB tuners running
echo -n -1 > /sys/module/usbcore/parameters/autosuspend
eos
  end
  File.chmod(0755, LEADTEK_INIT)
  `update-rc.d leadtek defaults`

  puts "\t#{LEADTEK_INIT} created"
else
  puts "\t#{LEADTEK_INIT} exists"
end

puts "\nSetup remote control for DVT2000DS\n"
unless File.exists?("/usr/local/bin/ir-keytable") then
  puts "\tInstall required libraries for remote..."
  install("libjpeg-dev")

  puts "\tInstall ir-keytable from source"
  `cd /tmp;git clone http://linuxtv.org/git/v4l-utils.git`
  `cd /tmp/v4l-utils;autoreconf -vfi;./configure;make`
  `cd /tmp/v4l-utils/utils/keytable; cp ir-keytable /usr/local/bin`
  `cd /tmp/v4l-utils/utils/keytable; cp rc_keymaps /etc`
end

unless File.exists?(file = "/etc/udev/rules.d/20-mythtv.rules") then
  puts "\tSetup rule for remote"

  File.open(file, "w") do |f|
    f.write <<-eos 
# Leadtek DTV2000DS Remote Control
KERNELS=="2-1",ATTRS{idVendor}=="0413",ATTRS{idProduct}=="6a04",SYMLINK+="input/dtv2000ds_remote"
eos
  end
end

unless File.exists?(filebak = "/etc/lirc/hardware.conf.bak") then
  puts "\tSetup hardware.conf"
  file = "/etc/lirc/hardware.conf"

  File.rename(file, filebak)
  File.open(file, "w") do |f|
    f.write <<-eos
# /etc/lirc/hardware.conf

REMOTE="Leadtek dtv2000ds y04g0051"
REMOTE_MODULES=""
REMOTE_DRIVER="devinput"
REMOTE_DEVICE="/dev/input/dtv2000ds_remote"
REMOTE_LIRCD_CONF="/etc/lirc/lircd.conf"
REMOTE_LIRCD_ARGS=""

#Chosen IR Transmitter
TRANSMITTER="None"
TRANSMITTER_MODULES=""
TRANSMITTER_DRIVER=""
TRANSMITTER_DEVICE=""
TRANSMITTER_LIRCD_CONF=""
TRANSMITTER_LIRCD_ARGS=""

#Enable lircd
START_LIRCD="true"

#Don't start lircmd even if there seems to be a good config file
#START_LIRCMD="false"

#Try to load appropriate kernel modules
LOAD_MODULES="true"

# Default configuration files for your hardware if any
LIRCMD_CONF=""

#Forcing noninteractive reconfiguration
#If lirc is to be reconfigured by an external application
#that doesn't have a debconf frontend available, the noninteractive
#frontend can be invoked and set to parse REMOTE and TRANSMITTER
#It will then populate all other variables without any user input
#If you would like to configure lirc via standard methods, be sure
#to leave this set to "false"
FORCE_NONINTERACTIVE_RECONFIGURATION="true"
START_LIRCMD="true"
eos
  end
end

puts "\n\n\nNow you can start mythtv-setup and on scan choose"
puts "import and enter /home/<user>/.mythtv/channels.conf"

