#!/bin/bash

apt update

apt install linux-image-amd64 linux-headers-amd64 firmware-linux firmware-linux-free firmware-linux-nonfree firmware-realtek grub2 cryptsetup lvm2 initramfs-tools locales

update-initramfs -k all -u -v

dpkg-reconfigure tzdata
dpkg-reconfigure locales

tasksel

useradd -m -G sudo -s /bin/bash maddak
passwd maddak
passwd

grub-install --target=i386-pc --debug --force --recheck /dev/sda
