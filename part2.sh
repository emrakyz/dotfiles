#!/bin/bash

# This script installs and configures a fully functioning, completely
# configured Gentoo Linux system. The script should be run after chrooting.

# Define URLs for the files here:
# Useflags for specific packages.
URL_DOTFILES="https://github.com/emrakyz/dotfiles.git"
# PACKAGES WE INSTALL ##
URL_DEPENDENCIES_TXT="https://raw.githubusercontent.com/emrakyz/dotfiles/main/dependencies.txt"
# PORTAGE FILES #
URL_PACKAGE_USE="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/package.use"
URL_ACCEPT_KEYWORDS="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/package.accept_keywords"
URL_PACKAGE_ENV="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/package.env"
URL_USE_MASK="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/profile/use.mask"
URL_PACKAGE_UNMASK="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/profile/package.unmask"
# SPECIFIC COMPILER ENVIRONMENTS #
URL_CLANG_O3_LTO="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/env/clang_o3_lto"
URL_CLANG_O3_LTO_FPIC="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/env/clang_o3_lto_fpic"
URL_GCC_O3_LTO="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/env/gcc_o3_lto"
URL_GCC_O3_LTO_FFATLTO="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/env/gcc_o3_lto_ffatlto"
URL_GCC_O3_NOLTO="https://raw.githubusercontent.com/emrakyz/dotfiles/main/portage/env/gcc_o3_nolto"
# LINUX KERNEL CONFIGURATION #
URL_KERNEL_CONFIG="https://raw.githubusercontent.com/emrakyz/dotfiles/main/kernel_6_6_2_config"
# FIREFOX RELATED #
URL_USER_JS="https://raw.githubusercontent.com/arkenfox/user.js/master/user.js"
URL_UPDATER_SH="https://raw.githubusercontent.com/arkenfox/user.js/master/updater.sh"
URL_USER_OVERRIDES_JS="https://raw.githubusercontent.com/emrakyz/dotfiles/main/user-overrides.js"
URL_USERCHROME_CSS="https://raw.githubusercontent.com/emrakyz/dotfiles/main/userChrome.css"
URL_USERCONTENT_CSS="https://raw.githubusercontent.com/emrakyz/dotfiles/main/userContent.css"
URL_TEXLIVE_PROFILE="https://raw.githubusercontent.com/emrakyz/dotfiles/main/texlive.profile"
URL_TEXLIVE_INSTALL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
# ZSH PLUGINS #
URL_FZF_TAB="https://github.com/Aloxaf/fzf-tab.git"
URL_ZSH_AUTOSUGGESTIONS="https://github.com/zsh-users/zsh-autosuggestions.git"
URL_SYNTAX_HIGHLIGHT="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
URL_POWERLEVEL10K="https://github.com/romkatv/powerlevel10k.git"
# UBLOCK SETTINGS BACKUP #
URL_UBLOCK_BACKUP="https://raw.githubusercontent.com/emrakyz/dotfiles/main/ublock_backup.txt"
# BLACKLISTED ADRESSES TO BLOCK #
# THE BELOW LINK BLACKLISTS ADWARE, #
# MALWARE, FAKENEWS, GAMBLING, PORN, SOCIAL MEDIA #
URL_HOSTS_BLACKLIST="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
# TELEGRAM WEBCORD UPSCAYL #
URL_TELEGRAM_TAR_XZ="https://telegram.org/dl/desktop/linux"
URL_WEBCORD_APPIMAGE="https://github.com/SpacingBat3/WebCord/releases/download/v4.5.2/WebCord-4.5.2-x64.AppImage"
URL_UPSCAYL_APPIMAGE="https://github.com/upscayl/upscayl/releases/download/v2.9.1/upscayl-2.9.1-linux.AppImage"
# Settings for Busybox to only enable udhcpc and its scripts.
URL_BUSYBOX_CONFIG="https://raw.githubusercontent.com/emrakyz/dotfiles/main/busybox-9999"
URL_DEFAULT_SCRIPT="https://raw.githubusercontent.com/emrakyz/dotfiles/main/default.script"
URL_UDHCPC_INIT="https://raw.githubusercontent.com/emrakyz/dotfiles/main/udhcpc"
# Local Gentoo Repos.
URL_LOCAL="https://github.com/emrakyz/local.git"

# DEFINE DIRS HERE #
FILES_DIR="/root/files"
PORTAGE_DIR="/etc/portage"
PORTAGE_PROFILE_DIR="/etc/portage/profile"
PORTAGE_ENV_DIR="/etc/portage/env"
LIBREW_PROF_DIR="" # This will be defined later.
LIBREW_CHROME_DIR="$LIBREW_PROF_DIR/chrome"
LINUX_DIR="/usr/src/linux"
NEW_KERNEL="$LINUX_DIR/arch/x86/boot/bzImage"
KERNEL_PATH="/boot/EFI/BOOT/BOOTX64.EFI"
BUSYBOX_CONFIG_DIR="/etc/portage/savedconfig/sys-apps"
UDHCPC_INIT_DIR="/etc/init.d"
UDHCPC_SCRIPT_DIR="/etc/udhcpc"
LOCAL_REPO_DIR="/var/db/repos"

# Fail Fast & Fail Safe on errors and stop.
set -Eeo pipefail

# Create a logfile to inspect later if needed.
exec > >(tee -a logfile.txt) 2>&1

# Custom logging function for better readability.
log_info() {
    # ANSI escape code for cyan color.
    local CYAN='\033[0;36m'
    # ANSI escape code to reset color.
    local NC='\033[0m' # No Color.

    # Display the entire message in cyan.
    echo -e "${CYAN}$(date '+%Y-%m-%d %H:%M:%S') INFO: $1${NC}"
}

# Error handler function. This will show which command failed.
handle_error () {
    error_status=$?
    command_line=${BASH_COMMAND}
    error_line=${BASH_LINENO[0]}
    echo "$(date '+%Y-%m-%d %H:%M:%S') Error on line $error_line: command '${command_line}' exited with status: $error_status" |
    tee -a error.log.txt
}

trap 'handle_error' ERR
trap 'handle_error' RETURN

# Prepare the environment.
prepare_env() {
    source /etc/profile
    export PS1="(chroot) ${PS1}"
}

# Collect the first needed variables.
collect_variables() {
    # Ask the user the boot partition first.
    read -rp "Enter the Boot Partition (e.g /dev/nvme0n1p1): " PARTITION_BOOT

    # Ask the timezone.
    read -rp "Enter the Timezone (e.g. Europe/Berlin): " TIME_ZONE

    # Ask the GPU.
    read -rp "Enter your GPU (e.g nvidia): " GPU

    # Ask if the user has other disks they want to mount.
    read -rp "Do you have another partition you want to mount with boot? (y,n): " EXTERNAL_HDD

    # If the user said yes, then continue with the below questions; otherwise, skip.
    [[ "$EXTERNAL_HDD" =~ [Yy](es)? ]] && {
        read -rp "Which partition is it? (e.g /dev/sda1): " PARTITION_EXTERNAL
        read -rp "What's the format of that partition? (e.g ext4): " FORMAT_EXTERNAL
	read -rp "What's the path to mount? (e.g /mnt/harddisk): " MOUNT_DIR
	mkdir -p "$MOUNT_DIR"
    } || log_info "No extra partitions specified. Skipping..."

    # Find partitions mounted to / and /boot. then get their IDs.
    # These are needed for configuring the kernel and fstab.
    PARTITION_ROOT="$(findmnt -n -o SOURCE /)"

    UUID_ROOT="$(blkid -s UUID -o value "$PARTITION_ROOT")"
    UUID_BOOT="$(blkid -s UUID -o value "$PARTITION_BOOT")"
    PARTUUID_ROOT="$(blkid -s PARTUUID -o value "$PARTITION_ROOT")"
    [[ "$EXTERNAL_HDD" =~ [Yy](es)? ]] && EXTERNAL_UUID="$(blkid -s UUID -o value "$PARTITION_EXTERNAL")"
}

# Check if above variables properly collected.
check_first_vars() {
    # Check if the boot partition exists.
    { lsblk "$PARTITION_BOOT" > /dev/null 2>&1
    } || { log_info "Partition $PARTITION_BOOT does not exist."; exit 1; }

    # Check if the timezone given appropriate.
    TZ_FILE="/usr/share/zoneinfo/${TIME_ZONE}"
    { [ -f "$TZ_FILE" ]
    } || { log_info "The timezone $TIME_ZONE is invalid or does not exist."; exit 1; }

    # Check if all IDs collected properly.
    { [ -n "$UUID_ROOT" ] && [ -n "$UUID_BOOT" ] && [ -n "$PARTUUID_ROOT" ]
    } || { log_info "Critical partition information is missing."; exit 1; }

    # Check if GPU given is appropriate.
    # We define the proper GPUs in the list below.
    valid_gpus="via v3d vc4 virgl vesa ast mga qxl i965 r600 i915 r200 r100 r300 lima omap r128 radeon geode vivante nvidia fbdev dummy intel vmware glint tegra d3d12 exynos amdgpu nouveau radeonsi virtualbox panfrost lavapipe freedreno siliconmotion"

    # Check if the entered GPU is in the list of valid GPUs and does not contain spaces.
    { [[ "$valid_gpus" =~ $GPU ]] && [[ ! "$GPU" =~ [[:space:]] ]]
    } || { log_info "Invalid GPU. Please enter a valid GPU."; exit 1; }
}

# Account information is needed in order to create a user.
collect_credentials() {
    read -rp "Enter the New Username: " USERNAME
    read -rsp "Enter the New Password: " PASSWORD
    echo " "
    read -rsp "Confirm the New Password: " PASSWORD2
}

# Check if the given credentials are proper.
check_credentials() {
    # Check if the username contains only alphanumeric characters, underscores, and dashes.
    [[ "$USERNAME" =~ ^[a-zA-Z0-9_-]+$ ]] || {
    log_info "Invalid username. Only alphanumeric characters, underscores, and dashes are allowed."; exit 1; }

    # Check if passwords match and are not empty.
    { [ "$PASSWORD" = "$PASSWORD2" ] && [ -n "$PASSWORD" ]
    } || { log_info "Passwords do not match or are empty."; exit 1; }
}

# File Associations with URL, Download Location, and Final Destination.
declare -A associate_files

associate_f() {
    local key=$1
    local url=$2
    local base_path=$3

    # Constructing the final path by appending the key to the base path.
    local final_path="$base_path/$key"

    associate_files["$key"]="$url $FILES_DIR/$key $final_path"
}

# Set file associations. Updating could be singular but there is no need
# since it's instant and not problematic.
update_associations() {
    associate_f "package.use" "$URL_PACKAGE_USE" "$PORTAGE_DIR"
    associate_f "package.accept_keywords" "$URL_ACCEPT_KEYWORDS" "$PORTAGE_DIR"
    associate_f "package.env" "$URL_PACKAGE_ENV" "$PORTAGE_DIR"
    associate_f "use.mask" "$URL_USE_MASK" "$PORTAGE_PROFILE_DIR"
    associate_f "package.unmask" "$URL_PACKAGE_UNMASK" "$PORTAGE_PROFILE_DIR"
    associate_f ".config" "$URL_KERNEL_CONFIG" "$LINUX_DIR"
    associate_f "user.js" "$URL_USER_JS" "$LIBREW_PROF_DIR"
    associate_f "updater.sh" "$URL_UPDATER_SH" "$LIBREW_PROF_DIR"
    associate_f "user-overrides.js" "$URL_USER_OVERRIDES_JS" "$LIBREW_PROF_DIR"
    associate_f "userChrome.css" "$URL_USERCHROME_CSS" "$LIBREW_CHROME_DIR"
    associate_f "userContent.css" "$URL_USERCONTENT_CSS" "$LIBREW_CHROME_DIR"
    associate_f "clang_o3_lto" "$URL_CLANG_O3_LTO" "$PORTAGE_ENV_DIR"
    associate_f "clang_o3_lto_fpic" "$URL_CLANG_O3_LTO_FPIC" "$PORTAGE_ENV_DIR"
    associate_f "gcc_o3_lto" "$URL_GCC_O3_LTO" "$PORTAGE_ENV_DIR"
    associate_f "gcc_o3_nolto" "$URL_GCC_O3_NOLTO" "$PORTAGE_ENV_DIR"
    associate_f "gcc_o3_lto_ffatlto" "$URL_GCC_O3_LTO_FFATLTO" "$PORTAGE_ENV_DIR"
    associate_f "ublock_backup.txt" "$URL_UBLOCK_BACKUP" "$USER_HOME"
    associate_f "blacklist_hosts.txt" "$URL_HOSTS_BLACKLIST"
    associate_f "fzf-tab" "$URL_FZF_TAB" "$ZDOTDIR"
    associate_f "zsh-autosuggestions" "$URL_ZSH_AUTOSUGGESTIONS" "$ZDOTDIR"
    associate_f "zsh-fast-syntax-highlighting" "$URL_SYNTAX_HIGHLIGHT" "$ZDOTDIR"
    associate_f "powerlevel10k" "$URL_POWERLEVEL10K" "$ZDOTDIR"
    associate_f "texlive.profile" "$URL_TEXLIVE_PROFILE" "$TEX_DIR"
    associate_f "dependencies.txt" "$URL_DEPENDENCIES_TXT"
    associate_f "dotfiles" "$URL_DOTFILES"
    associate_f "telegram.tar.xz" "$URL_TELEGRAM_TAR_XZ" "$LOCAL_BIN_DIR"
    associate_f "webcord.AppImage" "$URL_WEBCORD_APPIMAGE" "$LOCAL_BIN_DIR"
    associate_f "upscayl.AppImage" "$URL_UPSCAYL_APPIMAGE" "$LOCAL_BIN_DIR"
    associate_f "busybox-9999" "$URL_BUSYBOX_CONFIG" "$BUSYBOX_CONFIG_DIR"
    associate_f "default.script" "$URL_DEFAULT_SCRIPT" "$UDHCPC_SCRIPT_DIR"
    associate_f "udhcpc" "$URL_UDHCPC_INIT" "$UDHCPC_INIT_DIR"
    associate_f "local" "$URL_LOCAL" "$LOCAL_REPO_DIR"
    associate_f "install-tl-unx.tar.gz" "$URL_TEXLIVE_INSTALL"
}

update_associations

# Move the files according to associative array.
move_file() {
    local key=$1
    local custom_destination=${2:-}  # Optional custom destination.
    local download_path final_destination
    IFS=' ' read -r _ download_path final_destination <<< "${associate_files[$key]}"

    # Move the file.
    mv "$download_path" "$final_destination"
}

# Display the progress bar.
update_progress() {
    local total=$1
    local current=$2
    local pct="$(( (current * 100) / total ))"

    # Clear the line and display the progress bar.
    printf "\rProgress: [%-100s] %d%%" "$(printf "%-${pct}s" | tr ' ' '#')" "$pct"
}

# Determine and handle download type.
download_file() {
    local source=$1
    local dest=$2

    # Check for directory existence and skip Git cloning if it exists.
    [ -d "$dest" ] && {
        log_info "Directory $dest already exists, skipping download."
        return
    }

    # Check for file existence and skip downloading if it exists.
    [ -f "$dest" ] && {
        log_info "File $dest already exists, skipping download."
        return
    }

    # Handling Powerlevel10k Git repository clone.
    [[ "$source" == *powerlevel10k* ]] && { git clone --depth=1 "$source" "$dest" > /dev/null 2>&1; return; }

    # Handling other Git repository clones.
    [[ "$source" == *".git" ]] && [[ "$source" != *powerlevel10k.git* ]] && { git clone "$source" "$dest" > /dev/null 2>&1; return; }

    # Handling regular file URLs.
    curl -L "$source" -o "$dest" > /dev/null 2>&1
}

# Function to Retrieve All Files with Progress Bar.
retrieve_files() {
    mkdir -p "$FILES_DIR"
    local total="$((${#associate_files[@]}))"
    local current=0

    for key in "${!associate_files[@]}"; do
        current="$((current + 1))"
        update_progress "$total" "$current"

        IFS=' ' read -r source dest _ <<< "${associate_files[$key]}"
        download_file "$source" "$dest"
    done
}

# Check the files we downloaded.
check_files() {
    local missing_files=()
    local pid_array=()
    local file_path

    # Check each file in the background and record missing ones.
    for key in "${!associate_files[@]}"; do
	IFS=' ' read -r source dest _ <<< "${associate_files["$key"]}"
        file_path="$dest"

        # Background process for checking file or repo existence.
        ( [ -s "$file_path" ] || [ -d "$file_path" ] || echo "$file_path" ) &
        pid_array+=($!)  # Store PID of background process.
    done

    # Wait for all background processes to complete.
    for pid in "${pid_array[@]}"; do
        wait "$pid" || missing_files+=("$(<&3)")
    done

    # Report missing files.
    for file in "${missing_files[@]}"; do
        log_info "Expected file or repository $file is missing or empty."
    done

    # If there are missing files, then stop.
    [ ${#missing_files[@]} -eq 0 ] || exit 1
}

# This command used several times in order to renew the environment after some changes.
renew_env() {
    env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
}

# Sync the Gentoo Repositories with the newest ones.
sync_repos() {
    emerge --sync --quiet
}

# Configure the localization settings.
configure_locales() {
    # Remove the "#" before English UTF setting.
    sed -i "/#en_US.UTF/ s/#//g" /etc/locale.gen

    # Generate locales after enabling English UTF.
    locale-gen

    # Select the generated locale.
    eselect locale set en_US.utf8

    # Add locales for the compiler.
    echo "LC_COLLATE=\"C.UTF-8\"" >> /etc/env.d/02locale

    # Renew the environment.
    renew_env
}

# Configure compiler flags for the global environment.
configure_flags() {
    # We will use the safest "-O2 -march=native -pipe" flags.
    # Add LDFLAGS AND RUSTFLAGS below FFLAGS.
    sed -i '/COMMON_FLAGS=/ c\COMMON_FLAGS="-march=native -O2 -pipe"
            /^FFLAGS/ a\LDFLAGS="-Wl,-O2 -Wl,--as-needed"
	    /^LDFLAGS/ a\RUSTFLAGS="-C debuginfo=0 -C codegen-units=1 -C target-cpu=native -C opt-level=3"' /etc/portage/make.conf

    # Find CPU flags and append them to make.conf file.
    # The command's output is not proper for make.conf so we modify it.
    emerge cpuid2cpuflags
    cpuid2cpuflags | sed 's/: /="/; s/$/"/' >> /etc/portage/make.conf

    # This program is not needed anymore. So it's removed.
    emerge --depclean cpuid2cpuflags

    # Enable rolling release packages and use the latest version targets.
    cat <<-EOF >> /etc/portage/make.conf
	ACCEPT_KEYWORDS="~amd64"
	RUBY_TARGETS="ruby32"
	RUBY_SINGLE_TARGET="ruby32"
	PYTHON_TARGETS="python3_12"
	PYTHON_SINGLE_TARGET="python3_12"
	LUA_TARGETS="lua5-4"
	LUA_SINGLE_TARGET="lua5-4"
	EOF
}

# Configure additional Portage features
configure_portage() {
    # We will accept all licenses by default.
    { echo "ACCEPT_LICENSE=\"*\""

      # Set the video card variable.
      echo "VIDEO_CARDS=\"$GPU\""

      # We will make it extra safe for precaution. So we don't use all cores.
      echo "MAKEOPTS=\"-j$(( $(nproc) - 2)) -l$(( $(nproc) - 2))\""

      # We will use idle mode for Portage in order to use the computer while compiling software.
      echo "PORTAGE_SCHEDULING_POLICY=\"idle\""

      # For the installation, it would be safer to compile single program at once.
      # We also set some sane defaults for the emerge command.
      echo "EMERGE_DEFAULT_OPTS=\"--jobs=1 --load-average=$(( $(nproc) - 2)) --keep-going --verbose --quiet-build --with-bdeps=y --complete-graph=y --deep\""

      # Disable default use flags and add sane defaults.
      echo "USE=\"-* minimal wayland pipewire clang native-symlinks lto pgo jit xs orc threads asm openmp libedit system-man system-libyaml system-lua system-bootstrap system-llvm system-lz4 system-sqlite system-ffmpeg system-icu system-av1 system-harfbuzz system-jpeg system-libevent system-librnp system-libvpx system-png system-python-libs system-webp system-ssl system-zlib system-boost\""

      # Some default self-defining features for Portage.
      echo "FEATURES=\"candy fixlafiles unmerge-orphans nodoc noinfo notitles parallel-install parallel-fetch clean-logs\""

      # This is needed for Mandoc. We will use Mandoc for manpages.
      echo "PORTAGE_COMPRESS_EXCLUDE_SUFFIXES=\"[1-9] n [013]p [1357]ssl\"
PORTAGE_COMPRESS=gzip"
    }  >> /etc/portage/make.conf
}

# Remove non-needed directories. Use text files instead.
remove_dirs() {
    rm -rf /etc/portage/package.use
    rm -rf /etc/portage/package.accept_keywords
}

# Configure package-specific useflags.
configure_useflags() {
    # Remove the directory first so we can use a text file instead.
    remove_dirs

    # Copy the Portage related files we downloaded.
    move_file package.use
    move_file package.accept_keywords
    move_file use.mask
    move_file package.unmask
}

# Move the custom compiler environment files. We move the files first but these will be
# activated after when we will have updated GCC and compiled Clang/Rust Toolchain.
move_compiler_env() {
    mkdir -p $PORTAGE_ENV_DIR
    move_file clang_o3_lto
    move_file clang_o3_lto_fpic
    move_file gcc_o3_lto
    move_file gcc_o3_nolto
    move_file gcc_o3_lto_ffatlto
}

# Now we can completely update the system.
update_system() {
    # Renew the environment just in case.
    renew_env

    # Use mandoc for manpages.
    emerge app-text/mandoc

    # Update all packages with new use flags and settings.
    emerge --update --newuse -e @world

    # Rebuild the packages that need to be because of shared files.
    emerge @preserved-rebuild

    # Remove the unnecessary packages.
    emerge --depclean

    # Renew again after the update.
    renew_env
}

# We will build these first and recompile again with their environment files.
build_clang_rust() {
    # Building Clang with GCC can be problematic so we will make it even slower.
    # We will only activate 2/3 of our threads. eg. 12 out of 16.
    NEW_MAKEOPTS="$(( $(nproc) * 2 / 3 ))"

    MAKEOPTS="-j$NEW_MAKEOPTS -l$NEW_MAKEOPTS" emerge dev-lang/rust sys-devel/clang

    # Since we have Clang/Rust Toolchain; we can activate their environment.
    # Now we will rebuild them with their own toolchain and then rebuild
    # the whole system excluding Clang/Rust toolchain.
    move_file package.env

    renew_env

    # Now we can rebuild whole toolchain related files with Clang/Rust toolchain
    # using optimizations.
    MAKEOPTS="-j$NEW_MAKEOPTS -l$NEW_MAKEOPTS" emerge --oneshot sys-devel/clang dev-libs/jsoncpp dev-libs/libuv sys-devel/llvm sys-devel/llvm-common sys-devel/llvm-toolchain-symlinks sys-devel/lld sys-libs/libunwind sys-libs/compiler-rt sys-libs/compiler-rt-sanitizers sys-devel/clang-common dev-util/cmake sys-devel/clang-runtime sys-devel/clang-toolchain-symlinks sys-libs/libomp dev-lang/rust dev-lang/perl dev-lang/python dev-util/ninja dev-util/samurai dev-python/sphinx dev-libs/libedit

    # Clean-up if needed.
    emerge --depclean

    # Rebuild GCC toolchain with its updated environment.
    emerge sys-devel/gcc
    renew_env
    emerge sys-libs/glibc sys-devel/binutils

    # Rebuild the world but exclude the packages we just compiled.
    emerge -e @world --exclude 'sys-devel/clang dev-libs/jsoncpp dev-libs/libuv sys-devel/llvm sys-devel/llvm-common sys-devel/llvm-toolchain-symlinks sys-devel/lld sys-libs/libunwind sys-libs/compiler-rt sys-libs/compiler-rt-sanitizers sys-devel/clang-common dev-util/cmake sys-devel/clang-runtime sys-devel/clang-toolchain-symlinks sys-libs/libomp dev-lang/rust dev-lang/perl dev-lang/python dev-util/ninja dev-util/samurai dev-python/sphinx dev-libs/libedit sys-devel/gcc sys-libs/glibc sys-devel/binutils'
}

# We can set the timezone now.
set_timezone() {
    # Remove the current time file if exists.
    rm /etc/localtime

    # Use our timezone variable.
    echo "$TIME_ZONE" > /etc/timezone

    # Configure timezone.
    emerge --config sys-libs/timezone-data
}

# We need the Intel Microcode updated specifically for our CPU.
set_cpu_microcode() {
    # First use a generic flac since we don't know the signature yet.
    echo "MICROCODE_SIGNATURES=\"-S\"" >> /etc/portage/make.conf

    # Emerge the microcode package.
    emerge intel-microcode

    # Now we have the package so we can learn the microcode now.
    SIGNATURE="$(iucode_tool -S 2>&1 | grep -o "0.*$")"

    # Change the temporal setting.
    sed -i "/MICROCODE/ s/-S/-s $SIGNATURE/" /etc/portage/make.conf

    # Recompile again with the new setting.
    emerge sys-firmware/intel-microcode
}

# Configure GPU Related Linux Firmware.
set_linux_firmware() {
    # Emerge without xz support since we don't have the kernel yet.
    USE="-compress-xz" emerge linux-firmware

    # pciutils is needed to find our GPU Code.
    emerge --oneshot pciutils

    # We need a sanitized output in order to use it.
    { [[ "$GPU" =~ nvidia ]] &&
        GPU_CODE="$(lspci | grep -i 'vga\|3d\|2d' |
	               sed -n '/NVIDIA Corporation/{s/.*NVIDIA Corporation \([^ ]*\).*/\L\1/p}' |
		       sed 's/m$//')"

        # Remove all Linux Firmware except the ones we need for the GPU.
        sed -i '/^nvidia\/'"$GPU_CODE"'/!d' /etc/portage/savedconfig/sys-kernel/linux-firmware-*
    } || log_info "Not using Nvidia... Skipping the debloating process for Linux Firmware."
}

# Solve the dependency conflict for text rendering and rasterization.
build_freetype() {
    # Freetype package should be compiled without Harfbuzz support first.
    USE="-harfbuzz" emerge --oneshot freetype

    # Then we can compile it again with Harfbuzz support.
    # Use oneshot since we don't want to add these into world file.
    emerge --oneshot freetype
}

# Now we can build the Gentoo Linux Kernel.
build_linux() {
    # Download the source for the lates Linux Kernel.
    emerge gentoo-sources

    # Use the variable we got at first.
    sed -i -e '/.*CONFIG_CMDLINE.*/c\' -e "CONFIG_CMDLINE=\"root=PARTUUID=$PARTUUID_ROOT\"" "$LINUX_DIR"/.config

    # Find our CPU Microcode Path.
    MICROCODE_PATH="$(iucode_tool -S -l /lib/firmware/intel-ucode/* 2>&1 |
	             grep 'microcode bundle' |
		     awk -F': ' '{print $2}' |
		     cut -d'/' -f4-)"

    # We will add the number of threads in the kernel config.
    THREAD_NUM=$(nproc)

    # 1- Use the found CPU Microcode Path.
    # 2- Add the number of threads to the kernel config.
    # 3- Use the variable we got for our root partition in order to use Efistub.
    # 4- Enable OpenRC Init instead of SysVinit.
    sed -i "/CONFIG_EXTRA_FIRMWARE/ s/=.*/=\"$MICROCODE_PATH\"/
            /CONFIG_NR_CPUS/ s/=.*/=$THREAD_NUM/
            /.*CONFIG_CMDLINE.*/c CONFIG_CMDLINE=\"root=PARTUUID=$PARTUUID_ROOT init=/sbin/openrc-init\"" "$LINUX_DIR"/.config

    # Move our .config file we downloaded before.
    move_file .config

    # Set the configuration file.
    make -C "$LINUX_DIR" olddefconfig

    # Build the kernel.
    make -C "$LINUX_DIR" -j"$(nproc)"

    # Everytime a new kernel built, nvidia drivers need to be emerged.
    { [[ "$GPU" =~ nvidia ]] && emerge x11-drivers/nvidia-drivers
    } || log_info "Not using Nvidia... Skipping..."

    # Since we have the kernel, we can build linux-firmware with xz.
    emerge sys-kernel/linux-firmware

    # Install the modules.
    make -C "$LINUX_DIR" modules_install

    # Mount the boot partition in order to copy the kernel.
    mount "$PARTITION_BOOT" /boot

    # Create the necessary directory for UEFI.
    mkdir -p /boot/EFI/BOOT

    # Copy the kernel to its location.
    cp "$NEW_KERNEL" "$KERNEL_PATH"
}

# Create fstab file with our partition variables.
generate_fstab() {
    # This is the Boot partition.
    echo "UUID=$UUID_BOOT /boot vfat defaults,noatime 0 2" > /etc/fstab

    # This is the Root partition.
    echo "UUID=$UUID_ROOT / ext4 defaults,noatime 0 1" >> /etc/fstab

    # If the user has an external HDD.
    { [[ "$EXTERNAL_HDD" =~ [Yy](es)? ]]
    } && echo "UUID=$EXTERNAL_UUID /mnt/harddisk $FORMAT_EXTERNAL defaults,uid=1000,gid=1000,umask=022,noatime,nofail 0 2" >> /etc/fstab
}

# We will create a generic hosts file with our username and local ip.
# Then we will append blacklisted hosts to the same file.
# Hosts are mentioned at the top of the script.
configure_hosts() {
    # Add the username variable as the hostname.
    sed -i "s/hostname=.*/hostname=\"$USERNAME\"/" /etc/conf.d/hostname

    # Generic localhost settings as shown on Gentoo Wiki.
    { echo "127.0.0.1	$USERNAME	localhost"
      echo "::1		$USERNAME	localhost"
    } > /etc/hosts

    # Append an empty line.
    echo " " >> /etc/hosts

    # Modify the blacklisted hosts and append to the file in a clean way.
    # We exclude Reddit. Others can be similaryly excluded.
    grep -oE '^0[^ ]+ [^ ]+' "$FILES_DIR"/blacklist_hosts.txt |
    grep -vF '0.0.0.0 0.0.0.0' |
    sed "/0.0.0.0 a.thumbs.redditmedia.com/,+66d" >> /etc/hosts
}

# Busybox UDHCPC is only 24kb and gets the job done in the fastest way possible.
# It's completely enough for the vast majority. The minority knows themselves.
# This function is not that important. It's just for removing everything on Busybox
# except UDHCPC which is the only module we need.
configure_udhcpc() {
    # Emerge busybox with savedconfig useflag (we have it on our package.use file
    # that we downloaded before).
    emerge sys-apps/busybox

    # Remove the generic config so we can apply ours.
    rm -f /etc/portage/savedconfig/sys-apps/busybox-*

    # Move the configuration file to its place.
    # This removes everything from Busybox but Udhcpc.
    move_file busybox-9999

    # Emerge busybox with the savedconfig again.
    emerge sys-apps/busybox

    # We need a directory to put udhcpc script in.
    mkdir -p "$UDHCPC_SCRIPT_DIR"

    # Move the very minimal init scripts for udhcpc.
    # I even stripped the non-needed parts of it (for home users) further.
    # You can check them from their URLs.
    move_file default.script
    move_file udhcpc

    # This version of udhcpc does not even touch /etc/resolv.conf
    # So we create it with the DNS we want. We can use Quad9 DNS
    # known for privacy, security and speed.
    { echo "9.9.9.9"
      echo "149.112.112.112"
    } > /etc/resolv.conf

    # The scripts for udhcpc should be executable.
    chmod +x "$UDHCPC_SCRIPT_DIR"/default.script
    chmod +x "$UDHCPC_INIT_DIR"/udhcpc

    # Unmerge the default dhcpcd.
    emerge --unmerge net-misc/dhcpcd

    # Activate udhcpc service and start it.
    rc-update add udhcpc default
    rc-service udhcpc start
}

# We will enable parallel start and disable everything related to hwclock
# since it's not needed. It's better to use local clock if you dual boot.
configure_openrc() {
    sed -i 's/.*clock_hc.*/clock_hctosys="NO"/
            s/.*clock_sys.*/clock_systohc="NO"/
	    s/.*clock=.*/clock="local"/' /etc/conf.d/hwclock

    sed -i 's/.*rc_parallel.*/rc_paralllel="yes"/
            s/.*rc_nocolor.*/rc_nocolor="yes"/
	    s/.*unicode.*/unicode="no"/' /etc/rc.conf

    # OpenRC Init does not provide tty services by default.
    # This instruction can be found on the Gentoo Wiki.
    # You can't boot into TTY without this.
    for n in $(seq 1 6); do ln -s /etc/init.d/agetty /etc/init.d/agetty.tty"$n"; rc-config add agetty.tty"$n" default; done
}

# We will create a user and passwords in a non-interactive way. Since we
# already collected the name and pass variables. We will also configure doas (a
# minimal sudo replacement). Pipewire does not have an OpenRC service we launch
# gentoo-pipewire-launcher at boot instead.
configure_accounts() {
    # In order to add our users to certain groups we need to compile some packages.
    # Seatd is the most minimal seat manager for Wayland.
    # Dcron is the most minimal cronjob manager.
    emerge sys-auth/seatd sys-process/dcron media-video/wireplumber media-video/pipewire app-admin/doas

    # Change root password.
    echo "root:$PASSWORD" | chpasswd

    # Allow the users that are in the wheel group.
    echo "permit :wheel" > /etc/doas.conf

    # Doas won't ask password from the main user.
    echo "permit nopass keepenv :$USERNAME" >> /etc/doas.conf

    # Doas won't ask password when you mistakenly run commands with doas
    # while logged in as the root user.
    echo "permit nopass keepenv :root" >> /etc/doas.conf

    # We put our user on groups in order to use the listed features.
    useradd -mG wheel,audio,video,usb,input,portage,pipewire,seat,cron "$USERNAME"

    # Use the first collected variables to set the username and the password non-interactively.
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Since we installed seatd, we need to add it to boottime in order to be able to login.
    rc-update add seatd default

    # Same for the cronjob manager.
    rc-update add dcron default
}

# We will disable Rsync Gentoo Repos and use git sync instead. It's much faster.
# We also enable other repositories in this step such as guru.
# Additionally, we will create our local repository.
configure_repos() {
    # We need these packages in order to use git sync and enable repos.
    emerge app-eselect/eselect-repository dev-vcs/git

    # Remove the default Gentoo repos.
    eselect repository remove gentoo

    # Add the new repos with git sync.
    eselect repository enable gentoo

    # Remove the files from default Gentoo repos.
    rm -rf /var/db/repos/gentoo

    # Add external repositories for librewolf brave and guru.
    eselect repository enable guru
    eselect repository add librewolf git https://codeberg.org/librewolf/gentoo.git
    eselect repository add brave-overlay git https://gitlab.com/jason.oliveira/brave-overlay.git

    # Add the local repository.
    eselect repository create "local"

    # We place the local repos we downloaded.
    move_file "local"

    # Create manifests for all local ebuilds.
    find "$LOCAL_REPO_DIR" -type f -name "*.ebuild" -exec ebuild {} manifest \;

    # Sync all of the repos using git.
    emaint sync -a
}

# This is very important. Without these modules started, you can't
# start Wayland compositors on Nvidia GPUs. This function will
# only run for machines with Nvidia GPUs.
add_nvidia_modules() {
    mkdir -p /etc/modules-load.d
    { echo "nvidia"
      echo "nvidia_modeset"
      echo "nvidia_uvm"
      echo "nvidia_drm"
    } >> /etc/modules-load.d/video.conf
}

# We have a list of dependencies (packages we want to install). We will install
# them together. This is the longest part since we install the browser and all
# other programs. Though we have Clang/Rust toolchain installed. So this
# shouldn't take too much time.
install_dependencies() {
    # Since we have our package list on each line we will modify the list as a
    # single line in order for the emerge command to work. We remove the comments
    # too.
    DEPLIST="$(sed -e 's/#.*$//' -e '/^$/d' "$FILES_DIR"/dependencies.txt | tr '\n' ' ')"

    # Now we can install the dependencies.
    emerge "$DEPLIST"
}

# We need to add the empty variables now since we have the $USERNAME.
# Then we need to update the associative array because it still
# has the empty ones.
initiate_new_vars() {
    USER_HOME="/home/$USERNAME"
    XDG_CONFIG_HOME="$USER_HOME/.config"
    ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    LOCAL_BIN_DIR="$USER_HOME/.local/bin"

    update_associations
}

# We place the dotfiles we downloaded into the new user's home folder. .cache
# is for colors. Even though this defaul repo does not use pywal, and uses exclusive
# colors; it uses pywal's neovim plugin to create an easy colorscheme for neovim.
place_dotfiles() {
    mv -f "$FILES_DIR/dotfiles/.config" "$USER_HOME"
    mv -f "$FILES_DIR/dotfiles/.local" "$USER_HOME"
    mv -f "$FILES_DIR/dotfiles/.cache" "$USER_HOME"

    # Some files should be executable such as Hyprland starting wrapper, lf previews, user scripts.
    chmod +x "$LOCAL_BIN_DIR"/*
    chmod +x "$XDG_CONFIG_HOME"/lf/*
    chmod +x "$XDG_CONFIG_HOME"/hypr/start.sh

    # We will use the lower-cased downloads folder.
    mkdir -p "$USER_HOME/downloads"
}

# Gentoo has its own way to easily configure fonts. We basically enable the
# most modern and advanced settings for font rendering and rasterization.
configure_fonts() {
    eselect fontconfig disable 10-hinting-slight.conf
    eselect fontconfig disable 10-no-antialias.conf
    eselect fontconfig disable 10-sub-pixel-none.conf
    eselect fontconfig enable 10-hinting-full.conf
    eselect fontconfig enable 10-sub-pixel-rgb.conf
    eselect fontconfig enable 10-yes-antialias.conf
    eselect fontconfig enable 11-lcdfilter-default.conf
}

# Create Librewolf profile. Install my setting files. Install extensions.
configure_librewolf() {
    # Start librewolf in headless mode in order to create config directory for it.
    doas -u "$USERNAME" librewolf --headless >/dev/null 2>&1 &
    sleep 3
    killall librewolf

    # Find the profile folder.
    LIBREW_PROF_DIR="$(sed -n "/Default=.*.default-release/ s/.*=//p" "$USER_HOME"/.librewolf/profiles.ini)"
    LIBREW_CHROME_DIR="$LIBREW_PROF_DIR/chrome"

    # userChrome.css and userContent.css files need to be placed in the chrome dir.
    mkdir -p "$LIBREW_CHROME_DIR"

    # Since we have new variables, renew the associations in order to move files properly.
    update_associations

    # Move the Librewolf configuration files.
    move_file user.js
    move_file user-overrides.js
    move_file updater.sh
    move_file userChrome.css
    move_file userContent.css

    # We need to make Arkenfox.js script executable.
    # And the user needs to own the .librewolf directory.
    chmod +x "$LIBREW_PROF_DIR"/updater.sh
    chown -R "$USERNAME":"$USERNAME" "$USER_HOME"/.librewolf

    # Run the Arkenfox.js script to apply the configuration files.
    doas -u "$USERNAME" "$LIBREW_PROF_DIR"/updater.sh -s -u

    # Create the directory for the extensions.
    EXT_DIR="$LIBREW_PROF_DIR/extensions"
    mkdir -p "$EXT_DIR"

    # These are the extensions we want to download.
    ADDON_NAMES=("ublock-origin" "istilldontcareaboutcookies" "vimium-ff" "minimalist-open-in-mpv" "darkreader")

    # For loop to download, extract, modify and move all extension properly.
    # Loop all listed addons.
    for ADDON_NAME in "${ADDON_NAMES[@]}"
    do
	# We first find the addon URL, curl it and then find the proper download link.
        ADDON_URL="$(curl --silent "https://addons.mozilla.org/en-US/firefox/addon/${ADDON_NAME}/" |
		           grep -o 'https://addons.mozilla.org/firefox/downloads/file/[^"]*')"

	    # We download the extension file with the extension.xpi name.
            curl -sL "$ADDON_URL" -o extension.xpi

	    # We unzip the files and search for the extension ID since librewolf
	    # Requires the ID  in the name. We also manipulate the text to make it
	    # usable.
            EXT_ID="$(unzip -p extension.xpi manifest.json | grep "\"id\"")"
            EXT_ID="${EXT_ID%\"*}"
            EXT_ID="${EXT_ID##*\"}"

            # We move the extension file to its proper location by naming it with
	    # its extension ID.
            mv extension.xpi "$EXT_DIR/$EXT_ID.xpi"
    done

    # Move the ublock setting backup in order to use later.
    move_file ublock_backup.txt
}

# Install the terminal file manager lf.
install_lf() {
    # This command will compile lf inside the go directory it creates.
    env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest

    # Move the compiled binary to the local binary directory.
    mv -f /root/go/bin/lf "$LOCAL_BIN_DIR"

    # Remove the unnecessary directory.
    rm -rf /root/go
}

# The below function will install TexLive with XeLaTeX support.
install_texlive() {
    # Download, configure and install texlive and some needed packages.
    tar -xzf "$FILES_DIR"/install-tl-unx.tar.gz

    # Extract directory name.
    TEX_DIR="$(find $FILES_DIR -maxdepth 1 -type d -name "install-tl-*")"

    update_associations

    move_file texlive.profile

    # Use the extracted directory name for running commands inside that directory.
    "$TEX_DIR"/install-tl -profile "$TEX_DIR"/texlive.profile

    # Install additional packages.
    tlmgr install apa7 biber biblatex geometry scalerel times
}

configure_shell() {
    # Create symlink for the shell profile file we downloaded.
    ln -s "/home/$USERNAME/.config/shell/profile" "/home/$USERNAME/.zprofile"

    # Change the default shell to Zsh.
    chsh --shell /bin/zsh "$USERNAME"

    # Link Dash to /bin/sh.
    ln -sfT /bin/dash /bin/sh

    # Move the plugins.
    move_file fzf-tab
    move_file zsh-autosuggestions
    move_file zsh-fast-syntax-highlighting
    move_file powerlevel10k
}

# Main function for the script. It informs us on every step with colored logs.
# So we know which step we are at, and if we succeeded. Since we have set -Eeo
# pipefail command enabled. The script only runs the success message if the
# command before succeeds.
main() {
    log_info "01 - Sourcing /etc/profile to set up the environment..."
    prepare_env
    log_info "01 - Done! /etc/profile has been sourced."

    log_info "02 - Collecting the first needed variables..."
    collect_variables
    log_info "02 - Done! Variables have been collected."

    log_info "03 - Checking the variables..."
    check_first_vars
    log_info "03 - Done! Variables are okay."

    log_info "04 - Collecting the credentials..."
    collect_credentials
    log_info "04 - Done! Credentials have been collected."

    log_info "05 - Checking the credentials..."
    check_credentials
    log_info "05 - Done! Credentials are okay."

    log_info "06 - Retrieving the needed files..."
    retrieve_files
    log_info "06 - Done! All needed files are retrieved."

    log_info "07 - Checking the files for safety..."
    check_files
    log_info "07 - Done! All needed files are present."

    log_info "08 - Syncing the Gentoo Repositories..."
    sync_repos
    log_info "08 - Done! Gentoo Repositories have been synced."

    log_info "09 - Configuring the locales..."
    configure_locales
    log_info "09 - Done! Locales have been configured."

    log_info "10 - Configuring the compiler flags..."
    configure_flags
    log_info "10 - Done! Compiler flags have been configured."

    log_info "11 - Configuring Portage settings..."
    configure_portage
    log_info "11 - Done! Portage has been configured."

    log_info "12 - Configuring the package-specific useflags..."
    configure_useflags
    log_info "12 - Done! Useflags have been configured."

    log_info "13 - Moving the custom compiler environment files..."
    move_compiler_env
    log_info "13 - Done! Custom compiler environment files have been moved."

    log_info "14 - Updating the system..."
    update_system
    log_info "14 - Done! The system is completely updated."

    log_info "15 - Building Clang/Rust Toolchain..."
    build_clang_rust
    log_info "15 - Done! The Clang/Rust toolchain is ready."

    log_info "16 - Setting up Timezone..."
    set_timezone
    log_info "16 - Done! Timezone is set."

    log_info "17 - Configuring Linux Firmware..."
    set_linux_firmware
    log_info "17 - Done! Linux Firmware has been configured."

    log_info "18 - Building Freetype..."
    build_freetype
    log_info "18 - Done! Freetype has been built."

    log_info "19 - Generating fstab file..."
    generate_fstab
    log_info "19 - Done! fstab has been generated."

    log_info "20 - Configuring hosts file..."
    configure_hosts
    log_info "20 - Done! hosts have been configured."

    log_info "21 - Setting up very minimal udhcpc client..."
    configure_udhcpc
    log_info "21 - Done! Busybox UDHCPC has been configured."

    log_info "22 - Configuring OpenRC settings..."
    configure_openrc
    log_info "22 - Done! OpenRC has been configured."

    log_info "23 - Configuring user and root account settings..."
    configure_accounts
    log_info "23 - Done! Account settings have been configured."

    log_info "24 - Configuring additional repos..."
    configure_repos
    log_info "24 - Done! Additional repos have been configured."

    [[ "$GPU" =~ nvidia ]] && {
    log_info "00 - Adding necessary Nvidia modules to boottime..."
    add_nvidia_modules
    log_info "00 - Done! Nvidia modules added to boottime."
    }

    log_info "25 - Initiating the new variables..."
    initiate_new_vars
    log_info "25 - Done! New variables have been created."

    log_info "26 - Placing the dotfiles..."
    place_dotfiles
    log_info "26 - Done! Dotfiles have been placed."

    log_info "27 - Configuring fonts..."
    configure_fonts
    log_info "27 - Done! Fonts have been configured."

    log_info "28 - Configuring Librewolf settings..."
    configure_librewolf
    log_info "28 - Done! Librewolf has been configured."

    log_info "29 - Installing the terminal file manager lf..."
    install_lf
    log_info "29 - Done! Lf has been installed."

    log_info "30 - Installing TexLive"
    install_texlive
    log_info "30 - Done! TexLive has been installed."

    log_info "31 - Configuring shell settings."
    configure_shell
    log_info "31 - Done! Shell settings have been configured."
}

main
