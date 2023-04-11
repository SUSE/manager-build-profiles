#!/bin/bash
# Copyright (c) 2018 SUSE LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 
#======================================
# Functions...
#--------------------------------------

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

set -euxo pipefail

mkdir /var/lib/misc/reconfig_system

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]-[$kiwi_profiles]..."

#======================================
# add missing fonts
#--------------------------------------
CONSOLE_FONT="eurlatgr.psfu"

#======================================
# prepare for setting root pw, timezone
#--------------------------------------
echo ** "reset machine settings"
sed -i 's/^root:[^:]*:/root:*:/' /etc/shadow
rm /etc/machine-id
rm /var/lib/zypp/AnonymousUniqueId
rm /var/lib/systemd/random-seed

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Specify default runlevel
#--------------------------------------
baseSetRunlevel 3

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#======================================
# If SELinux is installed, configure it like transactional-update setup-selinux
#--------------------------------------
if [[ -e /etc/selinux/config ]]; then
	# Check if we don't have selinux already enabled.
	grep ^GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub | grep -q security=selinux || \
	    sed -i -e 's|\(^GRUB_CMDLINE_LINUX_DEFAULT=.*\)"|\1 security=selinux selinux=1"|g' "/etc/default/grub"

	# Adjust selinux config
	sed -i -e 's|^SELINUX=.*|SELINUX=enforcing|g' \
	    -e 's|^SELINUXTYPE=.*|SELINUXTYPE=targeted|g' \
	    "/etc/selinux/config"

	# Move an /.autorelabel file from initial installation to writeable location
	test -f /.autorelabel && mv /.autorelabel /etc/selinux/.autorelabel
fi

##======================================
## Enable DHCP on eth0
##--------------------------------------
#cat >/etc/sysconfig/network/ifcfg-eth0 <<EOF
#BOOTPROTO='dhcp'
#MTU=''
#REMOTE_IPADDR=''
#STARTMODE='auto'
#ETHTOOL_OPTIONS=''
#USERCONTROL='no'
#EOF

systemctl disable wicked
systemctl enable NetworkManager
systemctl enable ModemManager

#======================================
# Enable cloud-init
#--------------------------------------
suseInsertService cloud-init-local
suseInsertService cloud-init
suseInsertService cloud-config
suseInsertService cloud-final

# Enable chrony
suseInsertService chronyd

#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'

echo FONT="$CONSOLE_FONT" >> /etc/vconsole.conf

# fix security level (boo#1171174)
sed -e '/^PERMISSION_SECURITY=s/easy/paranoid/' /etc/sysconfig/security
chkstat --set --system

#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
update-ca-certificates

#======================================
# Import trusted rpm keys
#--------------------------------------
for i in /usr/lib/rpm/gnupg/keys/gpg-pubkey*asc; do
    # importing can fail if it already exists
    rpm --import $i || true
done

# Add repos from /etc/YaST2/control.xml
if [ -x /usr/sbin/add-yast-repos ]; then
	add-yast-repos
	zypper --non-interactive rm -u live-add-yast-repos
fi

#======================================
# Enable kubelet if installed
#--------------------------------------
if [ -e /usr/lib/systemd/system/kubelet.service ]; then
	suseInsertService kubelet
fi

# Adjust zypp conf
# https://github.com/openSUSE/libzypp/issues/212
# in yast that's done in packager/cfa/zypp_conf.rb
sed -i 's/.*solver.onlyRequires.*/solver.onlyRequires = true/g' /etc/zypp/zypp.conf
sed -i 's/.*rpm.install.excludedocs.*/rpm.install.excludedocs = yes/g' /etc/zypp/zypp.conf
sed -i 's/^multiversion =.*/multiversion =/g' /etc/zypp/zypp.conf

#=====================================
# Configure snapper
#-------------------------------------
if [ "${kiwi_btrfs_root_is_snapshot-false}" = 'true' ]; then
        echo "creating initial snapper config ..."
        cp /etc/snapper/config-templates/default /etc/snapper/configs/root
        baseUpdateSysConfig /etc/sysconfig/snapper SNAPPER_CONFIGS root

	# Adjust parameters
	sed -i'' 's/^TIMELINE_CREATE=.*$/TIMELINE_CREATE="no"/g' /etc/snapper/configs/root
	sed -i'' 's/^NUMBER_LIMIT=.*$/NUMBER_LIMIT="2-10"/g' /etc/snapper/configs/root
	sed -i'' 's/^NUMBER_LIMIT_IMPORTANT=.*$/NUMBER_LIMIT_IMPORTANT="4-10"/g' /etc/snapper/configs/root
fi

# Enable jeos-firstboot if installed, disabled by combustion/ignition
if rpm -q --whatprovides jeos-firstboot >/dev/null; then
        mkdir -p /var/lib/YaST2
        touch /var/lib/YaST2/reconfig_system
        systemctl enable jeos-firstboot.service
fi

# The %post script can't edit /etc/fstab sys due to https://github.com/OSInside/kiwi/issues/945
# so use the kiwi custom hack
cat >/etc/fstab.script <<"EOF"
#!/bin/sh
set -eux

/usr/sbin/setup-fstab-for-overlayfs
# If /var is on a different partition than /...
if [ "$(findmnt -snT / -o SOURCE)" != "$(findmnt -snT /var -o SOURCE)" ]; then
	# ... set options for autoexpanding /var
	gawk -i inplace '$2 == "/var" { $4 = $4",x-growpart.grow,x-systemd.growfs" } { print $0 }' /etc/fstab
fi
EOF
chmod a+x /etc/fstab.script

# To make x-systemd.growfs work from inside the initrd
cat >/etc/dracut.conf.d/50-microos-growfs.conf <<"EOF"
install_items+=" /usr/lib/systemd/systemd-growfs "
EOF

#======================================
# Configure SelfInstall specifics
#--------------------------------------
if [[ "$kiwi_profiles" == *"SelfInstall"* ]]; then
	cat > /etc/systemd/system/selfinstallreboot.service <<-EOF
	[Unit]
	Description=SelfInstall Image Reboot after Firstboot (to ensure ignition and such runs)
	After=systemd-machine-id-commit.service
	Before=jeos-firstboot.service
	
	[Service]
	Type=oneshot
	ExecStart=rm /etc/systemd/system/selfinstallreboot.service
	ExecStart=rm /etc/systemd/system/default.target.wants/selfinstallreboot.service
	ExecStart=systemctl --no-block reboot

	[Install]
	WantedBy=default.target
	EOF
	ln -s /etc/systemd/system/selfinstallreboot.service /etc/systemd/system/default.target.wants/selfinstallreboot.service
fi

#======================================
# Boot TimeOut Configuration for iSCSI
#--------------------------------------
cat > /etc/systemd/system/iscsi-init-delay.service <<-EOF
[Unit]
# Workaround for boo#1198457 delay gen-initiatorname after local-fs
Description=One time delay for the iscsid.service
ConditionPathExists=!/etc/iscsi/initiatorname.iscsi
ConditionPathExists=/sbin/iscsi-gen-initiatorname
DefaultDependencies=no
RequiresMountsFor=/etc/iscsi
After=local-fs.target
Before=iscsi-init.service

[Install]
WantedBy=default.target

[Service]
Type=oneshot
RemainAfterExit=no
ExecStart=/sbin/iscsi-gen-initiatorname
EOF
ln -s /etc/systemd/system/iscsi-init-delay.service /etc/systemd/system/default.target.wants/iscsi-init-delay.service

#======================================
# Configure Pine64 specifics
#--------------------------------------
if [[ "$kiwi_profiles" == *"Pine64" ]]; then
    echo 'add_drivers+=" fixed sunxi-mmc axp20x-regulator axp20x-rsb "' > /etc/dracut.conf.d/sunxi_modules.conf
fi

#======================================
# Configure Raspberry Pi specifics
#--------------------------------------
if [[ "$kiwi_profiles" == *"RaspberryPi"* ]]; then
	# Add necessary kernel modules to initrd (will disappear with bsc#1084272)
	echo 'add_drivers+=" bcm2835_dma dwc2 "' > /etc/dracut.conf.d/raspberrypi_modules.conf

	# Add necessary kernel modules to initrd (will disappear with boo#1162669)
	echo 'add_drivers+=" pcie-brcmstb "' >> /etc/dracut.conf.d/raspberrypi_modules.conf

	# Work around network issues
  	cat > /etc/modprobe.d/50-rpi3.conf <<-EOF
		# Prevent too many page allocations (bsc#1012449)
		options smsc95xx turbo_mode=N
	EOF

	cat > /usr/lib/sysctl.d/50-rpi3.conf <<-EOF
		# Avoid running out of DMA pages for smsc95xx (bsc#1012449)
		vm.min_free_kbytes = 2048
	EOF
fi

#======================================
# Configure Vagrant specifics
#--------------------------------------
if [[ "$kiwi_profiles" == *"Vagrant"* ]]; then
        # create vagrant user
        useradd vagrant
        # allow password-less sudo
        echo "vagrant ALL=(ALL)NOPASSWD:ALL" > /etc/sudoers.d/vagrant
        # add vagrant's insecure key
        mkdir -p /home/vagrant/.ssh
        chmod 0700 /home/vagrant/.ssh
        cat > /home/vagrant/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
        chmod 0600 /home/vagrant/.ssh/authorized_keys
        chown -R vagrant /home/vagrant
fi

# Not compatible with set -e
baseCleanMount || true

exit 0
