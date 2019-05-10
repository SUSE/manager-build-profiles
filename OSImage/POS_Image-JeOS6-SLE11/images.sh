#!/bin/bash
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile
Echo "Configure image: [$name]..."

# set DEBUG=0 to enable debug log to $DEBUG_LOGFILE

#
# FUNCTIONS
#

# set DEBUG=1 to enable debug log to $DEBUG_LOGFILE
: ${DEBUG:=0}



#==========================================
# Striping unneed files
#------------------------------------------

# Strips doc files, keep only listed
baseStripDocs

# Strip locales, keep only listed
baseStripLocales en `echo $kiwi_language|tr ',' ' ' |sed -e "s|[@_.][^ ]*||g"`

# Strip translations
baseStripTranslations en `echo $kiwi_language|tr ',' ' ' |sed -e "s|[@_.][^ ]*||g"`

# Strip man pages
baseStripMans

# Strip info files
baseStripInfos

# delete unused boot splash
Rm -rf /usr/share/gfxboot/themes/{Zen,SuSE,SLES,NLD,SLED}

# delete devel files
Rm -rf `find -name "*.a"`
Rm -rf /usr/include/*

# uninstal packages
baseStripRPM

# created links for all supported busybox apps if it was installed
baseSetupBusyBox
# workaround for busybox syslog suse init service incompatibility 
test ! -f /etc/sysconfig/syslog && touch /etc/sysconfig/syslog
test ! -s /etc/syslog.conf && echo >/etc/syslog.conf

#==========================================
# umount /proc
#------------------------------------------
umount /proc

exit 0
