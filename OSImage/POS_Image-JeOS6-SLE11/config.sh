#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#======================================
# Activate services
#--------------------------------------
suseActivateDefaultServices
suseInsertService salt-minion
suseInsertService image_deployed
#======================================
# bnc#711424
#--------------------------------------

mknod /lib/udev/devices/fd0 b 2 0

#======================================
# SuSEconfig
#--------------------------------------
suseConfig

#wipe /etc/resov.conf so it do not contain build machine DNS
echo -n > /etc/resolv.conf 
#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

exit 0
