#!/usr/bin/zsh
PLUGIN_DIR=$(dirname $(readlink -f "$0"))

fpath+="${PLUGIN_DIR}/zsh-completions/src"
source "${PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
