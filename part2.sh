#!/bin/sh

source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/nvme0n1p1 /boot

emerge-webrsync
emerge --sync --quiet

echo "Europe/Istanbul" > /etc/timezone
emerge --config sys-libs/timezone-data

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

emerge sys-devel/gcc
emerge --autounmask-continue --keep-going --quiet-build --update --complete-graph --deep --newuse -e @world

emerge --autounmask-continue --quiet-build dev-vcs/git
emerge --autounmask-continue --quiet-build app-eselect/eselect-repository

eselect repository enable wayland-desktop
eselect repository enable guru
eselect repository enable pf4public
emaint sync -a

mkdir -p /etc/portage/savedconfig/sys-kernel
cd /etc/portage/savedconfig/sys-kernel
curl -LO raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/linux-firmware-99999999

emerge sys-kernel/linux-firmware sys-firmware/intel-microcode app-arch/lz4

emerge sys-kernel/gentoo-sources

cd /usr/src/linux
make mrproper
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/.config

KCFLAGS='-O2 -march=native -mtune=native -fomit-frame-pointer -pipe' KCPPFLAGS='-O2 -march=native -mtune=native -fomit-frame-pointer -pipe' make -j16
cd

mkdir -p /boot/EFI/BOOT
cp /usr/src/linux/arch/x86/boot/bzImage /boot/EFI/BOOT/BOOTX64.EFI

mkdir -p /mnt/harddisk

echo "UUID=3988-10B1 /boot vfat defaults,noatime 0 2
UUID=6e9d8fd8-f4b7-461d-ab43-c8cda4b170d4 / ext4 defaults,noatime 0 1
UUID=28F03D40F03D1612 /mnt/harddisk ntfs defaults,uid=1000,gid=1000,umask=022,noatime,nofail 0 2" > /etc/fstab

sed -i "s/hostname=.*/hostname=\"emre\"/g" /etc/conf.d/hostname

emerge net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start

sed -i 's/127.0.0.1.*/127.0.0.1\temre\tlocalhost/g' /etc/hosts
sed -i 's/::1.*/::1\t\temre\tlocalhost/g' /etc/hosts

sed -i 's/enforce=everyone/enforce=none/g' /etc/security/passwdqc.conf
echo -en "051104\n051104\n051104\n" | passwd

sed -i 's/#rc_parallel=\".*\"/rc_parallel=\"YES\"/g' /etc/rc.conf
sed -i 's/#unicode=\".*\"/unicode=\"YES\"/g' /etc/rc.conf
sed -i 's/clock=.*/clock=\"local\"/g' /etc/conf.d/hwclock

echo "nameserver 9.9.9.9
nameserver 149.112.112.112" > /etc/resolv.conf

echo "nohook resolv.conf" >> /etc/dhcpcd.conf

touch /etc/doas.conf
echo "permit :wheel
permit nopass keepenv :emre" > /etc/doas.conf

USE="-harfbuzz" emerge media-libs/freetype

curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/dependencies.txt
DEPLIST="`sed -e 's/#.*$//' -e '/^$/d' dependencies.txt | tr '\n' ' '`"
emerge $DEPLIST &&
rm -rf dependencies.txt &&

useradd -mG wheel,audio,video,portage,usb,seat emre
echo -en "051104\n051104\n051104\n" | passwd emre &&

cd /home/emre
git clone https://github.com/emrakyz/dotfiles.git
cd dotfiles
cp -r .local .config /home/emre
cd ..
rm -rf dotfiles
chmod +x /home/emre/.local/bin/*
chmod +x /home/emre/.config/hypr/start.sh

ln -s /home/emre/.config/shell/profile /home/emre/.zprofile

rc-update add seatd default

chown -R emre:emre /home/emre

chsh --shell /bin/zsh emre
ln -sfT /bin/dash /bin/sh

cd /usr/src/linux
make modules_install
efibootmgr -c -d /dev/nvme0n1 -p 1 -L "Gentoo" -l '\EFI\BOOT\BOOTX64.EFI'

emerge --depclean efibootmgr
emerge --depclean

mkdir -p /home/emre/.cache/zsh
touch /home/emre/.cache/zsh/history
cd
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
mv fast-syntax-highlighting /home/emre/.config/zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ./powerlevel10k
mv powerlevel10k /home/emre/.config/zsh

echo "nvidia
nvidia_modeset
nvidia_uvm
nvidia_drm" > video.conf
mkdir -p /etc/modules-load.d
mv video.conf /etc/modules-load.d

echo "====GENTOO INSTALLATION COMPLETED SUCCESSFULLY===="
