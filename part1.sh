#!/bin/sh

mkdir --parents /mnt/gentoo

mount /dev/nvme0n1p4 /mnt/gentoo

cd /mnt/gentoo

wget https://ftp.linux.org.tr/gentoo/releases/amd64/autobuilds/current-stage3-amd64-nomultilib-openrc/stage3-amd64-nomultilib-openrc-20221120T170155Z.tar.xz

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

rm -rf stage3-*.tar.xz

sed -i "s/-O2/-march=native -O2/g" /mnt/gentoo/etc/portage/make.conf

echo MAKEOPTS=\"-j17\" >> /mnt/gentoo/etc/portage/make.conf

mkdir --parents /mnt/gentoo/etc/portage/repos.conf

cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo /bin/bash
