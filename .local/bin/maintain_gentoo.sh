#!/bin/sh

[ "$(id -u)" -eq 0 ] || { echo "This script must be run as root" >&2; exit 1; }

USER=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' | head -n 1)

KERNEL_PATH="/boot/EFI/BOOT/BOOTX64.EFI"
NEW_KERNEL="/usr/src/linux/arch/x86/boot/bzImage"

MODULES_DIR="/lib/modules"
CACHE_DIR="/var/cache"
USER_CACHE_DIR="/home/$USER/.cache"
LOG_DIR="/var/log"
VAR_TMP_DIR="/var/tmp"

FAILED_LOG_DIR="$USER_CACHE_DIR/failed_builds"
FAILED_PACKAGES="$USER_CACHE_DIR/failed_packages.txt"

update_system() {
    mkdir -p "$FAILED_LOG_DIR"
    emaint sync -a
    emerge --update @world 2>&1 | grep -oP 'Failed to emerge \K[[:alnum:]_-]+/[[:alnum:]._-]+' > "$FAILED_PACKAGES"
    emerge @live-rebuild 2>&1 | grep -oP 'Failed to emerge \K[[:alnum:]_-]+/[[:alnum:]._-]+' >> "$FAILED_PACKAGES"
}

copy_failed_logs() {
while IFS= read -r pkg
do
    log_path="/var/tmp/portage/$pkg/temp/build.log"
    safe_pkg_name=$(echo "$pkg" | tr '/' '_')
    [ -f "$log_path" ] && cp "$log_path" "$FAILED_LOG_DIR/$safe_pkg_name.log"
done < "$FAILED_PACKAGES"
chown -R $USER:$USER "$FAILED_LOG_DIR"
}

update_kernel() {
    DIR_COUNT=$(find /usr/src/ -maxdepth 1 -type d -name 'linux-*' | wc -l)
    [ "$DIR_COUNT" -gt "1" ] || { echo "There is only one linux directory. The function stops..."; return; }

    KERNEL_DIR=$(find /usr/src/ -maxdepth 1 -type d -name 'linux-*' | sort -rV | head -n 1) &&
    OLD_KERNEL_DIR=$(find /usr/src/ -maxdepth 1 -type d -name 'linux-*' | sort -rV | head -n 2 | tail -n 1) &&

    cp "$OLD_KERNEL_DIR/.config" "$KERNEL_DIR" &&
    make -C "$KERNEL_DIR" olddefconfig &&
    make -C "$KERNEL_DIR" -j$(nproc) &&
    emerge nvidia-drivers &&
    make -C "$KERNEL_DIR" modules_install &&
    cp "$NEW_KERNEL" "$KERNEL_PATH" &&
    rm -rf "$OLD_KERNEL_DIR"
}

update_lfirmware() {
    FILE_COUNT_FIRMWARE=$(find /etc/portage/savedconfig/sys-kernel -maxdepth 1 -type f -name 'linux-*' | wc -l)
    [ "$FILE_COUNT_FIRMWARE" -gt "1" ] || { echo "There is only one firmware config. The function stops..."; return; }

    FIRMWARE_FILE=$(find /etc/portage/savedconfig/sys-kernel -maxdepth 1 -type f -name 'linux-*' | sort -rV | head -n 1) &&
    OLD_FIRMWARE_FILE=$(find /etc/portage/savedconfig/sys-kernel -maxdepth 1 -type f -name 'linux-*' | sort -rV | head -n 2 | tail -n 1) &&

    GPU_CODE=$(grep -o 'nvidia/[^ /]*' $OLD_FIRMWARE_FILE | head -n 1)

    sed -i '/^nvidia\/'"$GPU_CODE"'/!d' $FIRMWARE_FILE

    emerge linux-firmware

    rm -f $OLD_FIRMWARE_FILE
}

update_busybox() {
    FILE_COUNT_BUSYBOX=$(find /etc/portage/savedconfig/sys-apps -maxdepth 1 -type f -name 'linux-*' | wc -l)
    [ "$FILE_COUNT_BUSYBOX" -gt "1" ] || { echo "There is only one busybox config. The function stops..."; return; }

    BUSYBOX_FILE=$(find /etc/portage/savedconfig/sys-apps -maxdepth 1 -type f -name 'busybox-*' | sort -rV | head -n 1) &&
    OLD_BUSYBOX_FILE=$(find /etc/portage/savedconfig/sys-apps -maxdepth 1 -type f -name 'busybox-*' | sort -rV | head -n 2 | tail -n 1) &&

    BASENAME=$(basename $BUSYBOX_FILE)
    mv -f $OLD_BUSYBOX_FILE "/etc/portage/savedconfig/sys-apps/$BASENAME"

    emerge sys-apps/busybox
}

clean_old_modules() {
    cd "$MODULES_DIR" && ls -1v | head -n -1 | xargs rm -rf
}

clean_temp_files() {
    rm -rf "$CACHE_DIR"/* "$LOG_DIR"/* "$VAR_TMP_DIR"/*
}

clean_user_cache() {
    find "$USER_CACHE_DIR" -mindepth 1 -maxdepth 1 \( -name 'wal' -o -name 'youtube_channels' -o -name 'zsh' -o -name 'failed_builds' -o -name "failed_packages.txt" \) -prune -o -print0 | xargs -0 rm -rf
}

rm -rf "$FAILED_LOG_DIR"

update_system
update_kernel
update_lfirmware
update_busybox
copy_failed_logs
clean_old_modules
clean_temp_files
clean_user_cache
emerge --depclean

openrc-shutdown -p now
