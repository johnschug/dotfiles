# Start tmux
if (( $+commands[tmux] )) && [ -z "$TMUX" ]; then
  if [ -n "$SSH_CONNECTION" ]; then
    read -sk '?Press any key to continue...'
  fi
  if (( $+commands[systemd-run] )); then
    systemd-run --scope --user -qG tmux new -d -s DEFAULT &>/dev/null
  fi
  exec tmux new -A -s DEFAULT
fi

# Plugins
if [ -r "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/plugins.zsh" ]; then
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/plugins.zsh"
fi

export PAGER='less'
export LESS='-FRJgij4'
export LESSHISTFILE='-'
if (( $+commands[nvim] )); then
  export MANPAGER="env MANPATH=\"$MANPATH\" nvim -c 'set ft=man' -"
  export EDITOR='nvim'
  export MERGE='nvim -d'
else
  export MANPAGER="env MAN_PN=1 MANPATH=\"$MANPATH\" vim -M +MANPAGER -"
  export EDITOR='vim'
  export MERGE='vimdiff'
fi
export VISUAL="$EDITOR"
export SUDO_EDITOR='vim'

# Options
setopt append_create
setopt auto_cd
setopt auto_pushd
setopt complete_aliases
setopt complete_in_word
setopt correct
setopt extended_glob
setopt extended_history
setopt glob_complete
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt interactive_comments
setopt noclobber
setopt nolist_ambiguous
setopt notify
setopt pushd_ignore_dups

WORDCHARS="${WORDCHARS/\/}"
if [ "$EUID" -ne 0 ]; then
  HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history"
  SAVEHIST=1000
  HISTSIZE=1000
fi

# Bindings
export KEYTIMEOUT=5
bindkey -v
bindkey '^b' beginning-of-line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^h' backward-delete-char
bindkey '^?' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line
bindkey '^f' edit-command-line
bindkey '^k' insert-composed-char
bindkey '^v' insert-unicode-char
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end
bindkey '^t' cd-parent
bindkey '^o' cd-back
bindkey '^xo' insert-files
bindkey '^[s' toggle-sudo
bindkey "^['" toggle-quoted
bindkey -M vicmd '^f' edit-command-line
bindkey -M vicmd 'v' edit-command-line
bindkey -M vicmd 'q' push-input
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo
bindkey -M vicmd '~' vi-swap-case
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd '^o' cd-back
bindkey -M vicmd '^i' cd-forward

# Widgets
autoload -Uz edit-command-line insert-composed-char insert-unicode-char history-search-end insert-files
autoload -Uz split-shell-arguments modify-current-argument
zle -N edit-command-line
zle -N insert-composed-char
zle -N insert-unicode-char
zle -N insert-files
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

function zle-line-init zle-keymap-select zle-line-finish {
  psvar[1]="${${KEYMAP/vicmd/:}/(main|viins)/+}" # VI mode indicator
  zle reset-prompt
  zle -R
}
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

function toggle-quoted {
  local -a reply
  integer REPLY REPLY2
  split-shell-arguments
  if (( REPLY & 1 )); then
    (( REPLY-- ))
  fi

  local word=${reply[$REPLY]}
  if [[ "${(Q)word}" = "$word" ]]; then
    modify-current-argument '${(qq)${(Q)ARG}}'
  elif [[ "${(qq)${(Q)word}}" = "$word" ]]; then
    modify-current-argument '${(qqq)${(Q)ARG}}'
  else
    modify-current-argument '${(Q)ARG}'
  fi

  zle redisplay
}
zle -N toggle-quoted

function toggle-sudo {
  if [[ ! "$BUFFER" =~ ^su(do|)\  ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  elif [[ "$BUFFER" =~ ^sudo\  ]]; then
    (( CURSOR -= 5 ))
    BUFFER=${BUFFER#"sudo "}
  fi
}
zle -N toggle-sudo

function cd-parent {
  pushd .. &>/dev/null
  precmd
  zle reset-prompt
  zle zle-line-init
}
zle -N cd-parent

function cd-forward {
  emulate -L zsh
  setopt pushd_silent
  pushd -0
  precmd
  zle reset-prompt
  zle zle-line-init
}
zle -N cd-forward

function cd-back {
  emulate -L zsh
  setopt pushd_silent
  pushd +1
  precmd
  zle reset-prompt
  zle zle-line-init
}
zle -N cd-back

# Completion
autoload -Uz compinit bashcompinit
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' completer _oldlist _expand _complete _approximate _files _ignored
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BNo matches for: %d%b'
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3)) numeric)'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:processes' command "ps -u $USER -o pid,command"
zstyle ':completion:*:processes-names' command "ps -u $USER -o comm | uniq"

function {
  local zcompdump=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
  compinit -i -d "$zcompdump"
  if [[ -s "$zcompdump" && (! -e "$zcompdump.zwc" || "$zcompdump" -nt "$zcompdump.zwc") ]]; then
    zcompile "$zcompdump" &!
  fi
}
bashcompinit
compdef -n gpg2=gpg

# VCS Info
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' formats '([%b]%u%c)'
zstyle ':vcs_info:*' actionformats '([%b|%a]%u%c)'

function precmd {
  vcs_info
  psvar=("${${KEYMAP/vicmd/:}/(main|viins)/+}" "$vcs_info_msg_0_")
  print -Pf "${terminfo[tsl]}%s:%s${terminfo[fsl]}" '%n' '%1~'
}

# Prompt
function {
  if [ "${terminfo[colors]}" -gt 256 ] || [ "$COLORTERM" = "truecolor" ]; then
    local -A colors=(
      default "%{$(printf '\e[38;2;%lu;%lu;%lum' 0x65 0x7b 0x83)%}"
      user "%{$(printf '\e[38;2;%lu;%lu;%lum' 0x29 0x80 0xb9)%}"
      cwd "%{$(printf '\e[38;2;%lu;%lu;%lum' 0x1d 0x99 0xf3)%}"
      vcs "%{$(printf '\e[38;2;%lu;%lu;%lum' 0x7f 0x8c 0x8d)%}"
      fail "%{$(printf '\e[38;2;%lu;%lu;%lum' 0xdc 0x32 0x2f)%}"
    )
  elif [ "${terminfo[colors]}" -eq 256 ] && [ -n "$NOPALETTE" ]; then
    local -A colors=(default '%243F' user '%31F' cwd '%33F' vcs '%245F' fail '%160F')
  elif [ "${terminfo[colors]}" -ge 16 ]; then
    local -A colors=(default '%11F' user '%F{yellow}' cwd '%F{blue}' vcs '%12F' fail '%F{red}')
  else
    local -A colors=(default '%F{white}' user '%F{blue}' cwd '%F{cyan}' vcs '%F{white}' fail '%F{red}')
  fi

  PROMPT="${colors[default]}%1v%h ["
  PROMPT+="${colors[user]}%n"
  PROMPT+="${colors[default]}:${colors[cwd]}%(4~:%-1~/…/%2~:%~)"
  PROMPT+="%(2V: ${colors[vcs]}%2v:)"
  PROMPT+="${colors[default]}]"
  PROMPT+="%(0?::${colors[fail]}(%?%))%(!:#:$)%b%f "
}

# Aliases
autoload -Uz run-help
unalias run-help &>/dev/null
alias help=run-help
alias hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" ${terminfo[cols]}) | tr " " ='
alias ls='ls --color=auto'
alias l.=$'ls --color=auto -AI \'[^.]*\''
alias ll='ls --color=auto -l'
alias ll.=$'ls --color=auto -lAI \'[^.]*\''
alias info='info --vi-keys'
alias chown='chown -c --preserve-root'
alias chmod='chmod -c --preserve-root'
alias mkdir='mkdir -pv'
alias cp='cp -iv --reflink=auto --sparse=always'
alias mv='mv -iv'
alias ln='ln -iv'
alias rm='rm -Iv --preserve-root --one-file-system'
alias rename='rename -v'
alias mps='ps -u $USER'
alias ip='ip -c'
alias sudo='sudo '
alias sudop='sudo env PATH="$PATH" '
alias strace='strace -xy '
alias gdb='gdb -q '
alias vi='vim'
alias rvi='rvim'
if (( $+commands[gpg2] )); then
  alias gpg='gpg2'
fi
if (( $+commands[nvim] )); then
  alias vim='nvim'
  alias rvim='nvim -Z'
  alias view='nvim -R'
  alias bvim='nvim -b'
  alias bview='nvim -Rb'
else
  alias view='vim -R'
  alias bvim='vim -b'
  alias bview='vim -Rb'
fi
if (( $+commands[rg] )); then
  alias rg='rg -S'
  alias grep='rg -S'
  function vim-grep {
    vim -q <(rg --vimgrep --no-heading -S "$@")
  }
elif (( $+commands[ag] )); then
  alias grep='ag'
  function vim-grep {
    vim -q <(ag --vimgrep "$@")
  }
else
  alias grep='grep -ni --color=auto'
  function vim-grep {
    vim -q <(grep -srnH "$@")
  }
fi

if [ -r ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
