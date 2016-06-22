###Fresh Pxe Setup for Ubuntu Server 14.04 LTS
###Creator: Leo, 06-18-2016
###This script gathers packages and configures as necessary.
###Simply specify network parameters before you run the script
###Tested on Ubuntu Server 14.04.4 with a fresh Install

###Pxe Paramaters
subnet=192.168.5.0
netmask=255.255.255.0
gateway=192.168.5.1
broadcast=192.168.5.255
startip=192.168.5.30
endip=192.168.5.100
serverip=192.168.5.20
dns=8.8.8.8

###Folder Locations
isoimg=lubuntu-14.04.4-desktop-amd64.iso
tftproot=/tftpboot
bootfiles=lubuntu/14.04
kernel=lubuntu
#Boot files location resides in the tftp root directory.
#Dont include a "/" for bootfiles or kernel

###Automation Begin:
# Gathering Packages
#sudo apt-get update
#sudo apt-get install isc-dhcp-server xinetd tftpd-hpa syslinux nfs-kernel-Server





#Network Interface Setup
#File Destination: /etc/network/interfaces
echo auto eth0 > ~/pxe-files/interfaces
echo iface eth0 inet static >> ~/pxe-files/interfaces
echo address $serverip >> ~/pxe-files/interfaces
echo netmask $netmask >> ~/pxe-files/interfaces
echo network $subnet >> ~/pxe-files/interfaces
echo broadcast $broadcast >> ~/pxe-files/interfaces
printf "\n\e[34m Added Network Interface Settings \e[0m"
printf "\n\e[34m Fixing Permissions...\e[0m"
sudo chmod 644 ~/pxe-files/interfaces
sudo chown root ~/pxe-files/interfaces
sudo chgrp root ~/pxe-files/interfaces
printf "\e[32mDone.\e[0m"

#DHCP Setup
#File Destination: /etc/dhcp/dhcpd.conf
echo "default-lease-time 600;" > ~/pxe-files/dhcpd.conf
echo "max-lease-time 7200;" >> ~/pxe-files/dhcpd.conf

echo "subnet $subnet netmask 255.255.255.0 {" >> ~/pxe-files/dhcpd.conf
echo "range $startip $endip;" >> ~/pxe-files/dhcpd.conf
echo "option subnet-mask $netmask;" >> ~/pxe-files/dhcpd.conf
echo "option routers $serverip;" >> ~/pxe-files/dhcpd.conf
echo "option broadcast-address $broadcast;" >> ~/pxe-files/dhcpd.conf
echo "filename \"pxelinux.0\";" >> ~/pxe-files/dhcpd.conf
echo "next-server $serverip;" >> ~/pxe-files/dhcpd.conf
echo } >> ~/pxe-files/dhcpd.conf


printf "\n\e[34m Fixing Permissions...\e[0m"
sudo chmod 644 ~/pxe-files/dhcpd.conf
sudo chown root ~/pxe-files/dhcpd.conf
sudo chgrp root ~/pxe-files/dhcpd.conf
printf "\e[32mDone.\e[0m"



#File Destination: /etc/default/isc-dhcp-server
#sudo sed -i 's/INTERFACES=""/INTERFACES="eth0"/' /etc/default/isc-dhcp-server && printf "\n\e[32m Completed dhcp server config \e[0m"
#sudo chown root /etc/default/isc-dhcp-server
#sudo chgrp root /etc/default/isc-dhcp-server
#printf "\n\e[34m Configured Network Interfaces \e[0m"



#XINETD Setup
#Destination File: /etc/xinetd.d/tftp
echo service tftp > ~/pxe-files/tftp
echo { >> ~/pxe-files/tftp
echo 	socket_type	= dgram >> ~/pxe-files/tftp
echo protocol	= udp >> ~/pxe-files/tftp
echo wait	= yes >> ~/pxe-files/tftp
echo user	= root >> ~/pxe-files/tftp
echo server	= /usr/sbin/in.tftpd >> ~/pxe-files/tftp
echo server_args	= -s $tftproot >> ~/pxe-files/tftp
echo disable	= no >> ~/pxe-files/tftp
echo } >> ~/pxe-files/tftp


printf "\n\e[34m Fixing xinetd Permissions...\e[0m"
sudo chmod 644 ~/pxe-files/tftp
sudo chown root ~/pxe-files/tftp
sudo chgrp root ~/pxe-files/tftp
printf "\e[32mDone.\e[0m"


#sudo update-inetd --enable BOOT >/dev/null
#sudo service xinetd restart >/dev/null
#sudo service tftpd-hpa restart >/dev/null
#if netstat -lu | grep tftp >/dev/null;then
#	printf "\n\e[32m xinetd Setup Completed \e[0m\n";else
#	echo "Need to forward TFTP manually"
#	echo "Edit /etc/xinetd.d/tftp to Complete TFTP Setup" > ~/log.error
#fi




#TFTPD Setup
#Desktination File: /etc/default/tftpd-hpa
echo TFTP_USERNAME=\"tftp\" > ~/pxe-files/tftpd-hpa
echo TFTP_DIRECTORY=\"$tftproot\" >> ~/pxe-files/tftpd-hpa
echo TFTP_ADDRESS=\"[\:0.0.0.0\:]\:69\" >> ~/pxe-files/tftpd-hpa
echo TFTP_OPTIONS=\"--secure\" >> ~/pxe-files/tftpd-hpa
echo RUN_DAEMON=\"yes\" >> ~/pxe-files/tftpd-hpa
echo OPTIONS=\"-l -s $tftproot\" >> ~/pxe-files/tftpd-hpa

printf "\n\e[34m Fixing tftpd-hpa Permissions...\e[0m"
sudo chmod 644 ~/pxe-files/tftpd-hpa
sudo chown root ~/pxe-files/tftpd-hpa
sudo chgrp root ~/pxe-files/tftpd-hpa
printf "\e[32mDone.\e[0m"
printf "\n\e[34m TFTP Setup Completed \e[0m"



#Creating Boot Directories
printf "\n\e[34m Preparing Boot Directories...\e[0m"
sudo mkdir -p $tftproot/pxelinux.cfg/
sudo mkdir -p $tftproot/$bootfiles
sudo cp /usr/lib/syslinux/vesamenu.c32 $tftproot/
sudo cp /usr/lib/syslinux/pxelinux.0 $tftproot/
printf "\e[32mDone.\e[0m"

#Making PXE Menu File
printf "\n\e[34m Making PXE Menu...\e[0m"
echo DEFAULT vesamenu.c32 > ~/pxe-files/default
echo TIMEOUT 100 >> ~/pxe-files/default
echo PROMPT 0 >> ~/pxe-files/default
echo MENU TITLE Metech PXE Server >> ~/pxe-files/default
echo LABEL Lubuntu 64bit >> ~/pxe-files/default
	echo \	KERNEL $kernel/vmlinuz.efi >> ~/pxe-files/default
	echo \	APPEND initrd=$kernel/initrd.lz boot=casper netboot=nfs nfsroot=$serverip:$tftproot/$bootfiles >> ~/pxe-files/default
echo ENDTEXT >> ~/pxe-files/default
printf "\e[32mDone.\e[0m"
printf "\n\e[34m Fixing PXE Menu Permissions...\e[0m"
sudo chmod 644 ~/pxe-files/default
sudo chown root ~/pxe-files/default
sudo chgrp root ~/pxe-files/default
printf "\e[32mDone.\e[0m"



#NFS Exports
#Destination File: /etc/exports
printf "\n\e[34m Setting Up NFS Exports...\e[0m"
echo "$tftproot/$bootfiles *(ro,async,no_root_squash,no_subtree_check)" > ~/pxe-files/exports
#catecho "$tftproot/$bootfiles *(ro,async,no_root_squash,no_subtree_check)" >> ~/pxe-files/exports
sudo chmod 644 ~/pxe-files/exports
#sudo exportfs -a
#sudo /etc/init.d/nfs-kernel-server start >/dev/null
printf "\e[32mDone.\e[0m"
printf "\n\e[32m PXE Files are Ready \e[0m\n\n\n"
