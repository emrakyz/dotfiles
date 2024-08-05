#!/bin/dash

u="https://github.com/emrakyz/shared.git"
r="${XDG_DATA_HOME}/shared"
[ -d "${r}" ] || git clone "${u}" "${r}"

c=".config"
b=".local/bin"

s="${b}
${c}/dunst"

e="${b}/webcord
${b}/bins
${b}/piperr
${b}/Telegram
${b}/Updater
${b}/vtt.sh"

p() { printf "%s\n" "${@}"; }
g() { git -C "${r}" "${@}"; }
gd() { g diff "${1}"; }

p "${e}" > "/tmp/fl"

syn() {
        [ "$PWD" = "${r}" ] && d="${HOME}" || d="${r}"
        rsync -ahivzPR --stats --inplace --delete \
                --zc=zstd --zl=3 \
                --exclude-from="/tmp/fl" \
                ${s} "${d}"
}

psh() {
        cd "${HOME}" && syn
        read -rp "ENTER COMMIT MESSAGE:" m
        g add -A && g commit -m "${m}" && g push
}

mrg() {
        cd "${r}" && g pull --rebase && syn
}

drun() {
        [ "${1}" = mrg ] && { g fetch origin && gd ..origin/main; } || cd "${HOME}" && syn && gd main
        g ls-files --others --exclude-standard | xargs -r bat
}

case "${1}" in
        "-p") psh ;;
        "-m") mrg ;;
        "-dp") drun psh ;;
        "-dm") drun mrg ;;
        *) p "[-p|-m|-dp|-dm]" ;;
esac
