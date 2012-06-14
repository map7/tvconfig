#!/usr/bin/env ruby
#
# Hauppauge HVR-2200 dual tuner
# 2 x USB tuners on a PCI-E board.
#

require File.expand_path(File.dirname(__FILE__) + '/../lib/general.rb')
include General

install 'unzip'

TMP_DIR = "/tmp/hauppauge"
URL = "http://www.steventoth.net/linux/hvr22xx"
Dir.mkdir TMP_DIR unless File.exist?(TMP_DIR)
Dir.chdir TMP_DIR

# Download drivers & firmware
download("#{URL}/22xxdrv_27086.zip","#{TMP_DIR}/22xxdrv_27086.zip")
download("#{URL}/HVR-12x0-14x0-17x0_1_25_25271_WHQL.zip", "#{TMP_DIR}/HVR-12x0-14x0-17x0_1_25_25271_WHQL.zip")
download("#{URL}/firmwares/4038864/v4l-saa7164-1.0.3-3.fw","#{TMP_DIR}/v4l-saa7164-1.0.3-3.fw")
download("#{URL}/firmwares/4019072/NXP7164-2010-03-10.1.fw","#{TMP_DIR}/NXP7164-2010-03-10.1.fw")

# Download extraction script
extract = download("#{URL}/extract.sh","#{TMP_DIR}/extract.sh")

# Extract firmware
puts "Extract firmware from downloaded files"
`sh #{extract.path}`

# Copy firmware
kernel = %x[uname -r]
`sudo cp #{TMP_DIR}/*.fw /lib/firmware/#{kernel}`


