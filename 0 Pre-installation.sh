#!/bin/bash

################################################
#
#	sda
#		250		ext2		/boot
#		249800		luks, LVM
#			29800	ext4		/
#			100%	ext4		/home
#
#	sdb
#		620000		luks, ext2	~/storage
#		20000		cryp		swap
#
################################################

apt install debootstrap cryptsetup lvm2 git
git clone https://github.com/glacion/genfstab

cryptsetup --cipher=aes-xts-plain64 --key-size 512 --hash sha512 --iter-time=10000 --use-random luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 encrypted

pvcreate /dev/mapper/encrypted
vgcreate encrypted /dev/mapper/encrypted
lvcreate -L 29800MB -n root encrypted
lvcreate -l 100%FREE -n home encrypted

mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/mapper/encrypted-root
mkfs.ext4 /dev/mapper/encrypted-home

mkdir -v /installation
mount /dev/mapper/encrypted-root /installation
mkdir -v /installation/{boot,home}
mount /dev/sda1 /installation/boot
mount /dev/mapper/encrypted-home /installation/home

debootstrap --arch amd64 stable /installation http://deb.debian.org/debian/

mount -t proc /proc /installation/proc/
mount -t sysfs /sys /installation/sys/
mount -o bind /dev /installation/dev/

genfstab -U /installation >> /installation/etc/fstab
	# /dev/mapper/encrypted-swap 			none		swap 		sw		0 0

cp -vrf configurations/* /installation/etc

chroot /installation /bin/bash
