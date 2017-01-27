#!/usr/bin/zsh
PLUGIN_DIR=$(dirname $(readlink -f "$0"))

plugins=('zsh-completions' 'zsh-syntax-highlighting' 'zsh-autosuggestions')
for p in $plugins; do
  source "${PLUGIN_DIR}/${p}/${p}.plugin.zsh"
done
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=030"
