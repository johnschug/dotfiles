#!/usr/bin/zsh
function {
  local plugindir=${${(%):-%x}:A:h}
  local plugins=('zsh-completions' 'zsh-syntax-highlighting' 'zsh-autosuggestions')
  local p
  for p in $plugins; do
    if [ -f "${plugindir}/${p}/${p}.plugin.zsh" ]; then
      source "${plugindir}/${p}/${p}.plugin.zsh"
    fi
  done
}

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=030"
