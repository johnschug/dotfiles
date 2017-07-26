#!/usr/bin/zsh
export SKIM_DEFAULT_OPTIONS="--bind 'ctrl-t:toggle-sort'"
if hash rg &>/dev/null; then
  export SKIM_DEFAULT_COMMAND='rg --files'
elif hash ag &>/dev/null; then
  export SKIM_DEFAULT_COMMAND='ag -l -g ""'
fi

function {
  local plugindir=$(dirname $(readlink -f "${(%):-%x}"))
  local plugins=('zsh-completions' 'zsh-syntax-highlighting' 'zsh-autosuggestions' 'skim')
  local p
  for p in $plugins; do
    if [ -f "${plugindir}/${p}/${p}.plugin.zsh" ]; then
      source "${plugindir}/${p}/${p}.plugin.zsh"
    fi
  done
}

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=030"

bindkey '^ ' skim-cd-widget
bindkey '^o' skim-file-widget
bindkey '^r' skim-history-widget
