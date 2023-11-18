#!/bin/dash

[ "$(id -u)" = "0" ] || echo "This script should be run as root" >&2 && exit 1

USERNAME="$(grep 1000:1000 "/etc/passwd" | grep -o "^[[:alnum:]]*")"

echo "permit :wheel
permit nopass keepenv :$USERNAME
permit nopass keepenv :root" > "/etc/doas.conf"

echo "app-text/poppler cxx lcms jpeg utils
media-video/ffmpegthumbnailer jpeg png" >> "/etc/portage/package.use"

# Clean-up first
crontab -d -u $USERNAME
emerge --depclean zsh oh-my-zsh dcron && emerge --depclean
rm "/usr/bin/lf"
rm "/usr/local/bin/lf"
rm "/home/$USERNAME/.local/bin/lf"
rm "/home/$USERNAME/.local/share/history"
rm "/home/$USERNAME/*profile"
rm "/home/$USERNAME/*rc"
rm -rf "/home/$USERNAME/.cache/zsh"
rm -rf "/home/$USERNAME/.config/shell"
rm -rf "/home/$USERNAME/.config/zsh"
rm -rf "/home/$USERNAME/.local/share/fonts"

# Install Necessary Packages
emerge zoxide eza zsh zsh-completions gentoo-zsh-completions dcron sys-apps/bat app-shells/fzf media-video/ffmpegthumbnailer mediainfo media-fonts/noto-emoji

emerge --oneshot poppler

# Install LF
env CGO_ENABLED=0 go install -ldflags="-s -w" github.com/gokcehan/lf@latest
mv "/root/go/bin/lf" "/home/$USERNAME/.local/bin"
rm -rf "/root/go"

# Create necessary directories
mkdir -p "/home/$USERNAME/.config/shell"
mkdir -p "/home/$USERNAME/.config/zsh"
mkdir -p "/home/$USERNAME/.config/lf"
mkdir -p "/home/$USERNAME/.local/share/fonts"

git clone https://github.com/Aloxaf/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git

mv -iv fzf-tab zsh-autosuggestions fast-syntax-highlighting powerlevel10k "/home/$USERNAME/.config/zsh"
