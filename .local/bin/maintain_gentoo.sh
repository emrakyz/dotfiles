#!/bin/bash
set -Eeuo pipefail

[ "${UID}" = "0" ] || {
        echo "This script must be run as root"
        exit "0"
}

G='\e[1;92m' R='\e[1;91m' B='\e[1;94m'
P='\e[1;95m' Y='\e[1;93m' N='\033[0m'
C='\e[1;96m' W='\e[1;97m'

handle_err() {
        stat="${?}"
        cmd="${BASH_COMMAND}"
        line="${LINENO}"
        loginf r "Line ${B}${line}${R}: cmd ${B}'${cmd}'${R} exited with ${B}\"${stat}\""
}

kill_bglog() {
        [ "${pidlog}" ] && kill "${pidlog}" > "/dev/null"
}

loginf() {
        sleep "0.3"

        case "${1}" in
                g) COL="${G}" MSG="DONE!" ;;
                r) COL="${R}" MSG="WARNING!" ;;
                b) COL="${B}" MSG="STARTING." ;;
                c) COL="${B}" MSG="RUNNING." ;;
        esac

        TSK="${W}(${C}${TSKNO}${P}/${C}${ALLTSK}${W})"
        RAWMSG="${2}"

        DATE="$(date "+%Y-%m-%d ${C}/${P} %H:%M:%S")"

        LOG="${C}[${P}${DATE}${C}] ${Y}>>>${COL}${MSG}${Y}<<< ${TSK} - ${COL}${RAWMSG}${N}"

        { [[ ${1} == "c" ]] && echo -e "\n\n${LOG}"; } || echo -e "${LOG}"
}

USER="$(id -nu "1000")"

KERNEL_PATH="/boot/EFI/BOOT/BOOTX64.EFI"
NEW_KERNEL="/usr/src/linux/arch/x86/boot/bzImage"

MODULES_DIR="/lib/modules"
CACHE_DIR="/var/cache"
USER_CACHE_DIR="/home/${USER}/.cache"
LOG_DIR="/var/log"
VAR_TMP_DIR="/var/tmp"

renew_env() {
        env-update && source "/etc/profile"
}

sync_repos() {
        emaint sync -a > "/dev/null" 2>&1
}

update_world() {
        emerge --update "@world" 2>&1 || true
}

update_live() {
        emerge "@live-rebuild" 2>&1 || true
}

remove_unneeded() {
        CLEAN_DELAY="0" emerge --depclean -q --verbose=n > "/dev/null" 2>&1 || true
}

update_kernel() {
        DIR_COUNT="$(fd -d "1" -t "d" 'linux-.*' "/usr/src" | wc -l)"

        [ "${DIR_COUNT}" -gt "1" ] || {
                echo -e "${B}There is only one linux directory. The funct stops...${N}"
                return
        }

        KERNEL_DIR="$(fd -d "1" -t "d" 'linux-.*' "/usr/src" | sort -rV | head -n "1")"

        echo -e "${G}New kernel directory:${C} ${KERNEL_DIR} ${N}"

        OLD_KERNEL_DIR="$(fd -d "1" -t "d" 'linux-.*' "/usr/src" | sort -rV | head -n "2" | tail -n "1")"

        echo -e "${G}Old kernel directory:${C} ${OLD_KERNEL_DIR} ${N}"

        export LLVM="1" LLVM_IAS="1" CFLAGS="-O3 -march=native -pipe" KCFLAGS="-O3 -march=native -pipe"

        cp -fv "${OLD_KERNEL_DIR}/.config" "${KERNEL_DIR}"

        make -C "${KERNEL_DIR}" "olddefconfig" > "/dev/null" 2>&1
        make -C "${KERNEL_DIR}" -j"$(nproc)" > "/dev/null" 2>&1
        make -C "${KERNEL_DIR}" "modules_install" > "/dev/null" 2>&1

        cp -fv "${NEW_KERNEL}" "${KERNEL_PATH}"

        echo -e "${G}New kernel${C} ${NEW_KERNEL} ${G}has been copied to${C} ${KERNEL_PATH}.${N}"

        rm -rf "${OLD_KERNEL_DIR}"

        echo -e "${G}Old kernel directory${C} ${OLD_KERNEL_DIR} ${G}has been deleted.${N}"
}

preserve_rebuild() {
        emerge @preserved-rebuild
}

clean_old_modules() {
        fd -t "d" -d "1" . "${MODULES_DIR}" | head -n "-1" | xargs -P "0" rm -rf
}

clean_temp_files() {
        rm -rf "${CACHE_DIR:?}"/* "${LOG_DIR:?}"/* "${VAR_TMP_DIR:?}"/*
}

clean_user_cache() {
        fd -d "1" . "${USER_CACHE_DIR}" -E "youtube_channels" | xargs -P "0" rm -rf
}

run_fstrim() {
        fstrim -Av
}

own_home() {
        chown -R 1000:1000 "/home/${USER}"
}

handle_shutdown() {
        echo -e "${G}The system will shutdown."

        delay_shutdown="$(echo -e "No\nYes" | rofi -dmenu -l "2" -p "Want to delay shutdown?")"

        [ "${delay_shutdown}" = "Yes" ] && {
                while true; do
                        delay_amount="$(echo "" | rofi -dmenu -l "0" -p "Amount in minutes:")"

                        [ "${delay_amount}" ] || {
                                echo -e "Shutdown not delayed. Shutting down now."
                                openrc-shutdown -p "now"
                                break
                        }

                        [[ "${delay_amount}" =~ ^[0-9]+$ ]] || {
                                notify-send "Invalid input. Please enter a number."
                                continue
                        }

                        notify-send "Shutdown delayed by ${delay_amount} minutes."
                        sleep "$((delay_amount * 60))"

                        delay_shutdown="$(echo -e "No\nYes" | rofi -dmenu -l "2" -p "Want to delay shutdown?")"
                        [ "${delay_shutdown}" = "No" ] && {
                                openrc-shutdown -p "now"
                                break
                        }
                done
        } || openrc-shutdown -p "now"
}

main() {
        declare -A "tsks"

        tsks["renew_env"]="Renew the environment.
		       Environment renewed."

        tsks["sync_repos"]="Sync the Gentoo repositories.
		       Gentoo repositories synced."

        tsks["update_world"]="Update the world.
		         The world updated."

        tsks["update_live"]="Update live packages.
                        Live packages updated."

        tsks["remove_unneeded"]="Remove unneeded packages.
                            Unneeded packages removed."

        tsks["update_kernel"]="Update the kernel.
		          The kernel is ready."

        tsks["preserve_rebuild"]="Rebuild preserved libraries.
		          Preserved libraries rebuilt."

        tsks["clean_old_modules"]="Clean old kernel modules.
			      Old kernel modules cleaned."

        tsks["clean_temp_files"]="Clean temporary files.
                             Temporary files cleaned."

        tsks["clean_user_cache"]="Clean the user cache.
                             The user cache cleaned."

        tsks["run_fstrim"]="Own home directory.
                       Home directory owned."

        tsks["run_fstrim"]="Trim the filesystem.
                       Filesystem trimmed."

        tsk_ord=("renew_env" "sync_repos" "update_world" "update_live" "remove_unneeded"
                "update_kernel" "preserve_rebuild" "clean_old_modules" "clean_temp_files"
                "clean_user_cache" "run_fstrim" "own_home")

        ALLTSK="${#tsks[@]}"
        TSKNO="1"

        trap 'handle_err; kill_bglog' ERR RETURN
        trap 'kill_bglog' EXIT INT QUIT TERM

        for funct in "${tsk_ord[@]}"; do
                descript="${tsks[${funct}]}"
                descript="${descript%%$'\n'*}"

                msgdone="$(echo "${tsks[${funct}]}" | tail -n "1" | sed 's/^[[:space:]]*//g')"

                loginf b "${descript}"

                (
                        sleep "120"
                        while true; do
                                loginf c "${descript}"
                                sleep "120"
                        done || true
                ) &
                pidlog="${!}"

                "${funct}"
                loginf g "${msgdone}"

                [ "${TSKNO}" = "${ALLTSK}" ] && {
                        loginf g "All tsks completed."
                        kill "${pidlog}" 2> "/dev/null" || true
                        break
                }

                kill "${pidlog}" 2> "/dev/null" || true

                ((TSKNO++))
        done

        [ "${1}" = "-f" ] && openrc-shutdown -p "now" || "handle_shutdown"
}

main "${@}"
