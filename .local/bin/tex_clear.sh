#!/bin/sh

# Clears the build files of a LaTeX/XeLaTeX build.
# Run this file when exiting a .tex file.

[ "${1##*.}" = "tex" ] && {
	find "$(dirname "${1}")" -regex '.*\(_minted.*\|.*\.\(4tc\|xref\|tmp\|pyc\|pyg\|pyo\|fls\|vrb\|fdb_latexmk\|bak\|swp\|aux\|log\|synctex\(busy\)\|lof\|lot\|maf\|idx\|mtc\|mtc0\|nav\|out\|snm\|toc\|bcf\|run\.xml\|synctex\.gz\|blg\|bbl\)\)' -delete
} || printf "Provide a .tex file.\n"
