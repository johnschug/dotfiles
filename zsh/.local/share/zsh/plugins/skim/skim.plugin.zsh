if [[ $- != *i* ]]; then
  return
fi

if hash sk &>/dev/null; then
  __skimcmd='sk'
  __skimopts="SKIM_DEFAULT_OPTIONS"
elif hash fzf &>/dev/null; then
  __skimcmd='fzf'
  __skimopts="FZF_DEFAULT_OPTS"
  if [ -n "$SKIM_DEFAULT_COMMAND" ]; then
    export FZF_DEFAULT_COMMAND="$SKIM_DEFAULT_COMMAND"
  fi
  if [ -n "$SKIM_DEFAULT_OPTIONS" ]; then
    export FZF_DEFAULT_OPTS="$SKIM_DEFAULT_OPTIONS"
  fi
else
  return
fi

__fsel() {
  local item
  local cmd="${SKIM_FSEL_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | env "${__skimopts}=--reverse ${(P)__skimopts} ${SKIM_FSEL_OPTIONS}" $__skimcmd -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

skim-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle -N skim-file-widget

skim-cd-widget() {
  local cmd="${SKIM_CD_COMMAND:-"command find -L . -mindepth 1 -path '*/\\.*' -prune -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | env "${__skimopts}=--reverse ${(P)__skimopts} ${SKIM_CD_OPTS}" $__skimcmd -m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  local ret=$?
  typeset -f precmd >/dev/null && precmd
  zle reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle -N skim-cd-widget

skim-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -l 1 |
    env "${__skimopts}=--reverse ${(P)__skimopts} -n2..,.. --tac ${SKIM_HIST_OPTS} --query=${(q)LBUFFER} -m" $__skimcmd) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle -N skim-history-widget
