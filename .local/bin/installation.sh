#!/bin/bash

username="neuroleptic"

rm -fv "/usr/bin/lf"
rm -fv "/usr/local/bin/lf"
rm -fv "/home/$username/.local/bin/lf"
rm -fv "/home/$username/.local/share/history"
rm -fv "/home/$username/*profile"
rm -fv "/home/$username/*rc"
rm -rfv "/home/$username/.cache/zsh"
rm -rfv "/home/$username/.config/shell"
rm -rfv "/home/$username/.config/zsh"
rm -rfv "/home/$username/.local/share/fonts"

git clone https://github.com/emrakyz/dotfiles
cp -rfv "doftiles/.config" "/home/$username/"
cp -rfv "dotfiles/.local" "/home/$username/"
chmod +x "/home/$username/.local/bin/*"
chmod +x "/home/$username/.config/lf/*"
chmod +x "/home/$username/dunst/warn.sh"
chmod +x "/home/$username/hypr/start.sh"

git clone https://github.com/Aloxaf/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git

mv -fv fzf-tab zsh-autosuggestions fast-syntax-highlighting powerlevel10k "/home/$username/.config/zsh"
