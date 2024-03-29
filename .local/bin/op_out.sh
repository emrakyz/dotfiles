#!/bin/sh

# opout: "open output": A general handler for opening a file's intended output,
# usually the pdf of a compiled document.  I find this useful especially
# running from vim.

silent_open() {
        setsid -f "${@}" > /dev/null 2>&1
}

case "${1}" in
        *.tex | *.sil | *.m[dse] | *.[rR]md | *.mom | *.[0-9])
                silent_open xdg-open "$(get_comp_root.sh "${1}" || echo "${1%.*}").pdf"
                ;;
        *.html)
                silent_open "${BROWSER}" "${1%.*}.html"
                ;;
        *.sent)
                silent_open sent "${1}"
                ;;
esac
