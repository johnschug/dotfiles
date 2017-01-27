# Start tmux
if hash tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    if hash systemd-run &>/dev/null; then
      systemd-run --user --scope -q tmux new -d -s DEFAULT &>/dev/null
    fi
    exec tmux new -A -s DEFAULT
  fi
fi

# Plugins
if [ -f "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins/plugins.zsh" ]; then
  source "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins/plugins.zsh"
fi

# Options
setopt append_create
setopt auto_cd
setopt auto_pushd
setopt complete_aliases
setopt correct
setopt extended_glob
setopt extended_history
setopt glob_complete
setopt hist_ignore_all_dups
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt interactive_comments
setopt noclobber
setopt notify
setopt pushd_ignore_dups
setopt share_history

WORDCHARS="${WORDCHARS/\/}"
HISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/history"
SAVEHIST=200
HISTSIZE=1000

# Bindings
export KEYTIMEOUT=5
bindkey -v
bindkey '^h' backward-delete-char
bindkey '^?' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line
bindkey '^f' edit-command-line
bindkey '^k' insert-composed-char
bindkey '^v' insert-unicode-char
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^t' cd-parent
bindkey '^e' cd-undo
bindkey '^[s' insert-sudo
bindkey -M vicmd 'v' edit-command-line
bindkey -M vicmd 'q' push-input
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo
bindkey -M vicmd '~' vi-swap-case
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# VI mode indicator
function zle-line-init zle-keymap-select zle-line-finish {
  psvar[1]="${${KEYMAP/vicmd/:}/(main|viins)/+}"
  zle reset-prompt
  zle -R
}

function insert-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}

function cd-parent {
  pushd .. &>/dev/null
  precmd
  zle reset-prompt
}

function cd-undo {
  popd &>/dev/null
  precmd
  zle reset-prompt
}

autoload -Uz edit-command-line insert-composed-char insert-unicode-char history-search-end
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line
zle -N insert-composed-char
zle -N insert-unicode-char
zle -N insert-sudo
zle -N cd-parent
zle -N cd-undo
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

autoload -Uz add-zsh-hook cdr chpwd_recent_dirs compinit vcs_info zmv
compinit
add-zsh-hook chpwd chpwd_recent_dirs

# Completion
compdef gpg2=gpg
zstyle ':completion:*' use-compctl true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:approximate:*' max-errors 2
zstyle ':completion:*:processes' command 'ps --forest -e -o pid,user,tty,comm'
zstyle ':completion:*:processes-names' command 'ps -u ${USER} -o comm | uniq'
zstyle ':completion:*:*:kill:*:processes' command 'ps -o pid,tty,comm'

# VCS Info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' formats '([%b]%u%c)'
zstyle ':vcs_info:*' actionformats '([%b|%a]%u%c)'

function {
  case $TERM in
    termite|xterm*|rxvt*|(dt|k|E)term)
      _titlestart='\e]0;'
      _titlefinish='\a'
      ;;
    screen*)
      _titlestart='\ek'
      _titlefinish='\e\'
      ;;
    *)
      if tput hs; then
        _titlestart="$(tput tsl)"
        _titlefinish="$(tput fsl)"
      else
        function set-title {}
        return
      fi
  esac

  function set-title {
    print -Pn "$_titlestart$@$_titlefinish"
  }
}

function preexec {
  typeset -ig _starttime=SECONDS
}

function precmd {
  local elapsed=0
  if (( _starttime >= 0 )) ; then
    elapsed=$((SECONDS - _starttime))
  fi
  _starttime=-1

  vcs_info
  psvar=("${${KEYMAP/vicmd/:}/(main|viins)/+}" "$vcs_info_msg_0_" "$elapsed")
  set-title "%n${SSH_CLIENT:+@%m}:%1~"
}

# Prompt
function {
  if hash tput &>/dev/null; then
    local COLORS="$(tput colors)"
  else
    local COLORS=
  fi
  if [ "$COLORS" -gt 256 ] || [ "$COLORTERM" = "truecolor" ]; then
    local COLOR0="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x65 0x7b 0x83)%}"
    local COLOR1="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x29 0x80 0xb9)%}"
    local COLOR2="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x34 0x49 0x5e)%}"
    local COLOR3="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x1d 0x99 0xf3)%}"
    local COLOR4="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x7f 0x8c 0x8d)%}"
    local COLOR5="%{$(printf '\e[38;2;%lu;%lu;%lum' 0x85 0x99 0x00)%}"
    local COLOR6="%{$(printf '\e[38;2;%lu;%lu;%lum' 0xdc 0x32 0x2f)%}"
  elif [ -n "$NOPALETTE" ]; then
    local COLOR0="%243F"
    local COLOR1="%31F"
    local COLOR2="%25F"
    local COLOR3="%33F"
    local COLOR4="%245F"
    local COLOR5="%100F"
    local COLOR6="%160F"
  elif [ "$COLORS" -ge 16 ]; then
    local COLOR0="%11F"
    local COLOR1="%F{yellow}"
    local COLOR2="%F{magenta}"
    local COLOR3="%F{blue}"
    local COLOR4="%12F"
    local COLOR5="%F{green}"
    local COLOR6="%F{red}"
  else
    local COLOR0="%F{white}"
    local COLOR1="%F{blue}"
    local COLOR2="%F{blue}"
    local COLOR3="%F{cyan}"
    local COLOR4="%F{white}"
    local COLOR5="%F{green}"
    local COLOR6="%F{red}"
  fi

  PROMPT="${COLOR0}%1v%h ["
  PROMPT+="${COLOR1}%n"
  PROMPT+="${SSH_CLIENT:+${COLOR0}@${COLOR2}%m}"
  PROMPT+="${COLOR0}:${COLOR3}%3~"
  PROMPT+="%(2V. ${COLOR4}%2v.)"
  PROMPT+="${COLOR0}]%(!.#.$)%b%f "
  RPROMPT="${COLOR0}[%(0?.${COLOR5}%?.${COLOR6}%?) ${COLOR0}%3vs %j]%b%f"
}

# Aliases
alias ls='ls --color=auto'
alias l.='ls --color=auto -d .*'
alias ll='ls --color=auto -l'
alias ll.='ls --color=auto -l -d .*'
alias info='info --vi-keys'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias mkdir='mkdir -p'
alias cp='cp --reflink=auto --sparse=always'
alias cpv='rsync -pogh --progress'
alias ln='ln -v'
alias zcp='zmv -C'
alias zln='zmv -L'
alias sudop='sudo env PATH="$PATH"'
if hash nvim &>/dev/null; then
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

function clear-clipboard {
  printf '\n' | xclip -sel clip &>/dev/null
  if hash gpaste-client &>/dev/null; then
    gpaste-client empty &>/dev/null
  fi
  if hash qdbus &>/dev/null; then
    qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory &>/dev/null
  fi
}

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi