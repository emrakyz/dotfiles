#!/bin/bash

[ "${1}" == "-i" ] && {
    IPFS_MODE="true"
    shift
} || IPFS_MODE="false"

PURPLE='\e[1;95m' CYAN='\e[1;96m' WHITE='\e[1;97m'
GREEN='\e[1;92m' YELLOW='\e[1;93m' NC='\033[0m'
RED='\e[1;91m' BLUE='\e[1;94m'

USERAGENT="Mozilla/5.0 (Windows NT 10.0; rv:121.0) Gecko/20100101 Firefox/121.0"

FQUERY="$(printf "%s+" "${@}")"
QUERY="${FQUERY%+}"

URL="https://annas-archive.org/search?index=&q=${QUERY}&content=book_nonfiction&content=book_fiction&content=book_unknown&ext=pdf&acc=external_download&src=lgli&src=lgrs&sort=&lang=en&lang=_empty"

RESULTS="$(curl -A "${USERAGENT}" -s "${URL}" -X "GET" |
	sed '/partial matches/,$d')"

IFS=$'\n' read -r -d '' -a TITLES < <(echo "${RESULTS}" | grep -oP '(?<=<h3 class="max-lg:line-clamp-\[2\] lg:truncate leading-\[1.2\] lg:leading-\[1.35\] text-md lg:text-xl font-bold">)[^<]*' | head -n 25)
IFS=$'\n' read -r -d '' -a AUTHORS < <(echo "${RESULTS}" | grep -oP '(?<=<div class="max-lg:line-clamp-\[2\] lg:truncate leading-\[1.2\] lg:leading-\[1.35\] max-lg:text-sm italic">)[^<]*' | head -n 25)
IFS=$'\n' read -r -d '' -a PUBLISHERS < <(echo "${RESULTS}" | grep -oP '(?<=<div class="truncate leading-\[1.2\] lg:leading-\[1.35\] max-lg:text-xs">)[^<]*' | head -n 25)

IFS=$'\n' read -r -d '' -a URLS < <(echo "${RESULTS}" | grep -oP 'href="\K/md5/[^"]*' | head -n 25)
IFS=$'\n' read -r -d '' -a SIZES < <(echo "${RESULTS}" | grep -oP '(?<=pdf, )\d+(\.\d+)?MB' | head -n 25)

for i in "${!TITLES[@]}"; do
	TITLE="${TITLES[i]}"
	AUTHOR="${AUTHORS[i]}"
	PUBLISHER="${PUBLISHERS[i]}"
	SIZE="${SIZES[i]}"
	echo -e "${PURPLE}$((i + 1))) ${WHITE}Title: ${CYAN}${TITLE}${NC}"
	echo -e "${WHITE}Author: ${YELLOW}${AUTHOR}${NC}"
	[ -n "${PUBLISHER}" ] && echo -e "${WHITE}Publisher: ${GREEN}${PUBLISHER}${NC}"
	echo -e "${WHITE}Size: ${RED}${SIZE}${NC}"
	echo
done

echo -ne "${BLUE}Enter your selection: ${CYAN}"
read -r SELECTED_BOOK

CHOSEN_URL="${URLS[SELECTED_BOOK - 1]}"

FULL_URL="https://annas-archive.org${CHOSEN_URL}"

BOOK_PAGE_CONTENT="$(curl -A "${USERAGENT}" -s "${FULL_URL}" -X "GET")"

"${IPFS_MODE}" && {
	IPFS_LINKS="$(echo "${BOOK_PAGE_CONTENT}" | grep -oP "(?<=<a href=')[^']*ipfs[^']*")"
	echo -e "${RED}${IPFS_LINKS}${NC}"

	[ -z "${IPFS_LINKS}" ] && { echo "There is no IPFS link for this selection."; exit "0"; }
	echo -e "${BLUE}IPFS Links should be opened with a browser:${NC}"
	echo -e "${BLUE}Pinata is recommended:${NC}"
	exit "0"
}

LIBGEN_RS_LINK="$(echo "${BOOK_PAGE_CONTENT}" | grep -oP "(?<=<a href=')[^']*library\.lol[^']*")"
LIBGEN_LI_LINK="$(echo "${BOOK_PAGE_CONTENT}" | grep -oP "(?<=<a href=')[^']*libgen\.li[^']*")"

LIBGENLI_PAGE_CONTENT="$(curl -A "${USERAGENT}" -s "${LIBGEN_LI_LINK}" -X "GET")"
LIBGENRS_PAGE_CONTENT="$(curl -A "${USERAGENT}" -s "${LIBGEN_RS_LINK}" -X "GET")"

DOWNLOAD_LINK_LI="$(echo "${LIBGENLI_PAGE_CONTENT}" | grep -o 'https://cdn[0-9]*\.booksdl\.org[^"]*')"
DOWNLOAD_LINK_RS="$(echo "${LIBGENRS_PAGE_CONTENT}" | grep -o 'https://download.library.lol/.*.pdf')"

FILENAME="${QUERY//+/_}"
FILENAME="${FILENAME,,}.pdf"

DOWNLOAD_LINK_LI="${DOWNLOAD_LINK_LI//\\/\/}"
DOWNLOAD_LINK_RS="${DOWNLOAD_LINK_RS//\\/\/}"

echo -e "\n${GREEN}Downloading and renaming...${NC}"

MAX_RETRIES="10"
RETRY_DELAY="10"

for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
    [[ -n "${DOWNLOAD_LINK_RS}" && $((attempt % 2)) -ne 0 ]] && DOWNLOAD_LINK="${DOWNLOAD_LINK_RS}" || DOWNLOAD_LINK="${DOWNLOAD_LINK_LI}"

    echo -e "${GREEN}Attempt ${RED}${attempt} ${GREEN}of ${RED}${MAX_RETRIES}${NC}"

    curl -X "GET" -A "${USERAGENT}" -o "${FILENAME}" "${DOWNLOAD_LINK}"

    pdfinfo "${FILENAME}" > "/dev/null" 2>&1 && {
        echo -e "${GREEN}Download successful.${NC}"
        break
    } || {
        echo -e "${RED}Download failed, retrying in ${BLUE}${RETRY_DELAY} seconds...${NC}"
        sleep "${RETRY_DELAY}"
    }
done

pdfinfo "${FILENAME}" > "/dev/null" 2>&1 || echo "Download failed after ${MAX_RETRIES} attempts."
