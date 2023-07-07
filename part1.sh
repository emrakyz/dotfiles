#!/bin/sh

mkdir --parents /mnt/gentoo

mount /dev/nvme0n1p2 /mnt/gentoo

cd /mnt/gentoo

wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230319T170303Z/stage3-amd64-nomultilib-openrc-20230319T170303Z.tar.xz

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

rm -rf stage3-*.tar.xz

cd /mnt/gentoo/etc/portage
rm -rf make.conf package.use package.mask package.accept_keywords
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/make.conf
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.accept_keywords
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.use
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.env
cd /mnt/gentoo/etc/portage/profile
rm -rf use.mask package.unmask
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/use.mask
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.unmask
mkdir --parents /mnt/gentoo/etc/portage/env
cd /mnt/gentoo/etc/portage/env
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/env/clang-firefox
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/env/clang-thinlto
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/env/compiler-clang-nolto
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/env/compiler-clang-vapour
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/env/compiler-clang

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
