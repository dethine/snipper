#!/usr/bin/env bash
set -euo pipefail

# Simple utility script for building XRNX safely-ish

[[ "$#" -gt 0 ]] || (echo "$0 FILE_NAME.xrnx" >&2 && exit 1)

# Exclude common build dependencies, any type of dotfile (.env, .git, .vscode etc)
zip -r "${1}" . -x ".*" "build/*" "build.sh" "Makefile" "preferences.xml" \ "preferencesDynamicView.xml"
