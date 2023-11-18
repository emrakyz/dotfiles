HISTFILE="$XDG_DATA_HOME/history"

setopt append_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt nocaseglob
setopt extendedglob
setopt autocd
setopt completeinword
setopt nobgnice
setopt nohup

HISTSIZE=5000
SAVEHIST=5000

source "$HOME/.config/shell/aliasrc"

bindkey -v
export KEYTIMEOUT=1
bindkey -v '^?' backward-delete-char

autoload -U compinit
compinit

fpath=(/usr/share/zsh/site-functions $fpath)

function zle-keymap-select {
  [[ $KEYMAP == vicmd || $KEYMAP == visual ]] && echo -ne '\e[2 q' || echo -ne '\e[6 q'
}
zle -N zle-keymap-select
echo -ne '\e[6 q'
preexec() { echo -ne '\e[6 q' ;}

fzf-history-widget-with-date() {
  initial_query="$LBUFFER"
  setopt noglobsubst noposixbuiltins pipefail 2>/dev/null
  entry=$(fc -lir 1 |
          sed -E 's/^[[:space:]]+[0-9]+\*?[[:space:]]+//' |
          awk '{cmd=$0; $1=$2=$3=""; sub(/^[ \t]+/, ""); if (!seen[$0]++) print cmd}' |
          fzf --query="$initial_query" +s)
  [ -n "$entry" ] && LBUFFER=${entry#* * * }
  zle redisplay
}

zle -N fzf-history-widget-with-date
bindkey '^R' fzf-history-widget-with-date

fzf-cd-bookmark() {
    selection=$(cat "$XDG_CONFIG_HOME/shell/bm_dirs" | fzf | cut -f2)
    eval cd "$selection"
        for precmd_func in $precmd_functions; do
            $precmd_func
        done
    zle reset-prompt
}

zle -N fzf-cd-bookmark
bindkey '^J' fzf-cd-bookmark

source "$ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme"

source "$ZDOTDIR/.p10k.zsh"

source "$ZDOTDIR/zsh-autosuggestions/zsh-autosuggestions.zsh"

source "$ZDOTDIR/fzf-tab/fzf-tab.plugin.zsh"

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 -T --color=always --group-directories-first --icons $realpath'

eval "$(zoxide init zsh)"

source "$ZDOTDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" 2>/dev/null
