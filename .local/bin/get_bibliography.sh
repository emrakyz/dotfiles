#!/bin/dash

BIB_FILE="${HOME}/latex/uni.bib"

correction_method() {
        sed -n -E 's/.*((DOI|doi)((\.(org))?\/?|:? *))([^: ]+[^ .]).*/\6/p; T; q'
}

get_doi_from_pdf() {
        pdf="${1}"
        doi="$(pdfinfo "${pdf}" 2> "/dev/null" | correction_method)"

	[ -z "${doi}" ] && doi="$(pdftotext -q -l "2" "${pdf}" - 2> "/dev/null" | correction_method)"

	[ -z "${doi}" ] && printf "%s\n" "No DOI found for PDF: ${pdf}" >&2 && return "1"

	printf "%s\n" "${doi}"
}

correct_names() {
        sed 's/\}, /\},\n	/g
 	 s/, /,\n	/
         s/ }/\n}/
	 s/,\s*pages=/,\n\tpages=/' |
                sed '1s/^ *//
         1s/[0-9]*\([0-9]\{2\}\)/\1/
         1s/_//
         1s/.*/\L&/
	 s/.*=/\L&/
	 s/=/ = /'
}

process_doi() {
        doi="${1}"
        bibtex_entry="$(curl -s "https://api.crossref.org/works/${doi}/transform/application/x-bibtex" | correct_names)"
        red_color='\033[0;31m'
        reset_color='\033[0m'

        printf "${red_color}%s${reset_color}\n" "${bibtex_entry}"

	[ -z "${bibtex_entry}" ] && [ "$(printf "%s\n" "${bibtex_entry}" | cut -c2)" != "@" ] && {
		printf "%s\n" "Failed to fetch bibtex entry for DOI: ${doi}"
		return "1"
	}

        grep -iFq "doi = {${doi}}" "${BIB_FILE}" || {
                [ -s "${BIB_FILE}" ] && printf "%s\n" "" >> "${BIB_FILE}"
                printf "%s\n" "${bibtex_entry}" >> "${BIB_FILE}"
                printf "%s\n" "Added bibtex entry for DOI: ${doi}"
                return "0"
        }

        printf "%s\n" "Bibtex entry for DOI: ${doi} already exists in the file."
}

[ -z "${1}" ] && {
	printf "%s\n" "Give either a pdf file or a DOI or a directory path that has PDFs as an argument."
	exit "0"
}

[ -d "${1}" ] && {
        for pdf in "${1}"/*.pdf; do
                doi="$(get_doi_from_pdf "${pdf}")"
                [ -n "${doi}" ] && process_doi "${doi}"
        done

	exit "0"
}

[ -f "${1}" ] && [ "$(printf "%s\n" "${1}" | grep -c "\.pdf$")" -ne "0" ] && {
        doi="$(get_doi_from_pdf "${1}")"

	[ -n "${doi}" ] && {
                process_doi "${doi}"
                exit "0"
        }
}

doi="$(printf "%s\n" "${1}" | correction_method)"

[ -n "${doi}" ] && process_doi "${doi}"
