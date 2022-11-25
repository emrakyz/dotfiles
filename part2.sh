#!/bin/sh

source /etc/profile
export PS1="(chroot) ${PS1}"

mount /dev/nvme0n1p3 /boot

emerge-webrsync
emerge --sync --quiet

sed -i "s/-O2/-march=native -O2/g" /etc/portage/make.conf
echo ACCEPT_KEYWORDS=\"~amd64\" >> /etc/portage/make.conf
echo ACCEPT_LICENSE=\"*\" >> /etc/portage/make.conf
echo CPU_FLAGS_X86=\"aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3\" >> /etc/portage/make.conf
echo MAKEOPTS=\"-j17\" >> /etc/portage/make.conf

echo "Europe/Istanbul" > /etc/timezone
emerge --config sys-libs/timezone-data

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

emerge --quiet-build sys-devel/gcc
eselect gcc set 2
source /etc/profile
export PS1="(chroot) ${PS1}"

MAKEOPTS="-j1" emerge --jobs 1 --load-average 1 --quiet-build sys-apps/help2man

emerge --autounmask-continue --keep-going --quiet-build --update --complete-graph --deep --newuse --exclude sys-apps/help2man -e @world

emerge --autounmask-continue --quiet-build app-eselect/eselect-python
eselect python set python3.11

emerge --autounmask-continue --quiet-build dev-lang/ruby

emerge --autounmask-continue --quiet-build app-eselect/eselect-ruby
eselect ruby set 2

emerge --autounmask-continue --quiet-build dev-lang/rust

emerge --autounmask-continue --quiet-build dev-vcs/git

cd /etc/portage
rm -rf package.accept_keywords package.use package.mask
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.accept_keywords
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.use
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/package.mask
emerge --autounmask-continue --quiet-build app-eselect/eselect-repository
eselect repository enable mv
eselect repository enable lto-overlay
emaint sync -a

emerge --quiet-build sys-config/ltoize

echo "sys-devel/gcc lto pgo graphite jit" >> /etc/portage/package.use

MAKEOPTS="-j1" emerge --jobs 1 --load-average 1 --quiet-build sys-devel/gcc

rm -rf make.conf
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/make.conf
cd

sed -i "s/harfbuzz/-harfbuzz/g" /etc/portage/package.use
env-update
emerge --update --complete-graph --deep --newuse --exclude sys-devel/gcc -e @world

MAKEOPTS="-j1" emerge --jobs 1 --load-average 1 sys-devel/gcc 
MAKEOPTS="-j1" emerge --jobs 1 --load-average 1 sys-devel/clang

sed -i "s/-harfbuzz/harfbuzz/g" /etc/portage/package.use
emerge --update --complete-graph --deep --newuse --exclude 'sys-devel/gcc sys-devel/clang' -e @world 

emerge sys-kernel/linux-firmware sys-firmware/intel-microcode

echo "# Remove files that shall not be installed from this list.
nvidia/tu104/gr/fecs_bl.bin
nvidia/tu104/gr/gpccs_inst.bin
nvidia/tu104/gr/sw_veid_bundle_init.bin
nvidia/tu104/gr/fecs_data.bin
nvidia/tu104/gr/sw_bundle_init.bin
nvidia/tu104/gr/gpccs_sig.bin
nvidia/tu104/gr/sw_method_init.bin
nvidia/tu104/gr/gpccs_bl.bin
nvidia/tu104/gr/fecs_inst.bin
nvidia/tu104/gr/sw_nonctx.bin
nvidia/tu104/gr/sw_ctx.bin
nvidia/tu104/gr/gpccs_data.bin
nvidia/tu104/gr/fecs_sig.bin
nvidia/tu104/nvdec/scrubber.bin
nvidia/tu104/acr/unload_bl.bin
nvidia/tu104/acr/ucode_unload.bin
nvidia/tu104/acr/ucode_ahesasc.bin
nvidia/tu104/acr/bl.bin
nvidia/tu104/acr/ucode_asb.bin
nvidia/tu104/sec2/desc.bin
nvidia/tu104/sec2/sig.bin
nvidia/tu104/sec2/image.bin
nvidia/tu10x/typec/ccg_boot.cyacd
nvidia/tu10x/typec/ccg_primary.cyacd
nvidia/tu10x/typec/ccg_secondary.cyacd" > /etc/portage/savedconfig/sys-kernel/linux-firmware-20221109

emerge sys-kernel/linux-firmware

emerge sys-kernel/gentoo-sources

eselect kernel set 1

cd /usr/src/linux
make clean
rm -rf .config
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/.config

emerge app-arch/lz4
make -j15 && make modules_install
make install
cd

mkdir -p /boot/EFI/BOOT
cp /usr/src/linux/arch/x86/boot/bzImage /boot/EFI/BOOT/BOOTX64.EFI

mkdir -p /mnt/harddisk

echo "UUID=E1C2-03EF /boot vfat defaults,noatime 0 2
UUID=a417f98f-d5bb-4431-9d3b-163e097bb518 / ext4 defaults,noatime 0 1
UUID=28F03D40F03D1612 /mnt/harddisk ntfs defaults,uid=1000,gid=1000,umask=022,noatime,nofail 0 2" > /etc/fstab

sed -i "s/hostname=.*/hostname=\"emre\"/g" /etc/conf.d/hostname

emerge net-misc/dhcpcd
rc-update add dhcpcd default
rc-service dhcpcd start

sed -i 's/127.0.0.1.*/127.0.0.1\temre\tlocalhost/g' /etc/hosts
sed -i 's/::1.*/::1\t\temre\tlocalhost/g' /etc/hosts

sed -i 's/enforce=everyone/enforce=none/g' /etc/security/passwdqc.conf
echo -en "051104\n051104\n" | passwd

sed -i 's/#rc_parallel=\".*\"/rc_parallel=\"YES\"/g' /etc/rc.conf
sed -i 's/clock=.*/clock=\"local\"/g' /etc/conf.d/hwclock

curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/dependencies.txt
DEPLIST="`sed -e 's/#.*$//' -e '/^$/d' dependencies.txt | tr '\n' ' '`"
emerge --autounmask-write --autounmask-continue $DEPLIST
rm -rf dependencies.txt
MAKEOPTS="-j7" emerge --jobs 1 --load-average 7 --autounmask-continue app-office/libreoffice

mkdir -p /etc/X11/xorg.conf.d
cd /etc/X11/xorg.conf.d
touch nvidia.conf
echo "Section \"Device\"
   Identifier  \"nvidia\"
   Driver      \"nvidia\"
EndSection" >> nvidia.conf
cd

useradd -mG wheel,audio,video,portage,usb emre
echo -en "051104\n051104\n" | passwd emre

cd /home/emre
git clone https://github.com/emrakyz/dotfiles.git
cd dotfiles
cp -r .local .config /home/emre
cd ..
rm -rf dotfiles
chmod +x /home/emre/.local/bin/*
chmod +x /home/emre/.config/lf/scope /home/emre/.config/lf/cleaner

mkdir -p /home/emre/.local/src
cd /home/emre/.local/src
git clone https://github.com/emrakyz/dmenu.git
git clone https://github.com/emrakyz/st.git
git clone https://github.com/emrakyz/dwm.git
git clone https://github.com/nsxiv/nsxiv.git
git clone https://github.com/emrakyz/via.git

cd dmenu
make install
cd ..

cd st
make install
cd ..

cd dwm
make install
cd ..

cd nsxiv
curl -LO https://raw.githubusercontent.com/emrakyz/dotfiles/main/Portage/config.h
make install
cd ..

cd via
sudo make install
cd

ln -s /home/emre/.config/x11/xprofile /home/emre/.xprofile
ln -s /home/emre/.config/shell/profile /home/emre/.zprofile

rc-update add elogind boot

git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /home/emre/.config/zsh

chown -R emre:emre /home/emre

chsh --shell /bin/zsh emre
ln -sfT /bin/dash /bin/sh

echo "====GENTOO INSTALLATION COMPLETED SUCCESSFULLY===="
