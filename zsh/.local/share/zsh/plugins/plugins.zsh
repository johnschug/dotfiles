#!/usr/bin/zsh
function {
  local plugindir=${${(%):-%x}:A:h} p
  for p in "$plugindir"/*/*.plugin.zsh(r); do
    source $p
  done
}

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=030"
