autoload -U colors && colors
PS1="%B%{$fg[red]%}[%}%{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd
stty stop undef
setopt interactive_comments

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="/home/emre/.cache/zsh/history"

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

bindkey -v
export KEYTIMEOUT=1

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;
        viins|main) echo -ne '\e[5 q';;
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q'
preexec() { echo -ne '\e[5 q' ;}

lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'

bindkey -s '^a' '^ubc -lq\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export ANV_QUEUE_THREAD_DISABLE=1
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export MOZ_DBUS_REMOTE=1
export KCFLAGS=' -march=native -mtune=native'
export KCPPFLAGS=' -march=native -mtune=native'


# THIS IS FOR POMODORO TIMER #
declare -A pomo_options
pomo_options["work"]="52"
pomo_options["break"]="17"

pomodoro() {
  val=$1
  echo $val | lolcat
  timer ${pomo_options["$val"]}m
  spd-say "'$val' session done." -r -15 -t male3 -p -20
}

start_pomodoro() {
  # Number of times to repeat the loop, default is 2
  if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    num_loops=$1
  else
   # Default loops
    num_loops=2
  fi

  for i in $(seq 1 $num_loops); do
    pomodoro "work"
    pomodoro "break"
  done
}
change_pomo() {
  if [ -n "$1" ] && [ -n "$2" ]; then
    pomo_options["$1"]="$2"
    echo "The $1 time has been changed to $2 minutes"
  else
    echo "Please provide valid parameters: change_pomo [work/break] [time_in_minutes]"
  fi
}

alias doro=start_pomodoro
alias wo="pomodoro 'work'"
alias br="pomodoro 'break'"
alias c-p=change_pomo

source /home/emre/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

source /home/emre/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
