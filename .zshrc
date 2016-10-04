# Start tmux
if hash tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    if hash systemd-run &> /dev/null; then
      exec systemd-run --user --scope -q tmux new -A -s default
    else
      exec tmux new -A -s default
    fi
  fi
fi

# Plugins
if [ -f ~/.zsh/plugins/plugins.zsh ]; then
  source ~/.zsh/plugins/plugins.zsh
fi

# Options
setopt auto_cd
setopt complete_aliases
setopt correct
setopt extended_glob
setopt glob_complete
setopt interactive_comments
setopt notify

WORDCHARS="${WORDCHARS/\/}"

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
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^g' what-cursor-position
bindkey '^e' cd-parent
bindkey '^t' cd-undo
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

autoload -Uz edit-command-line insert-composed-char insert-unicode-char
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line
zle -N insert-composed-char
zle -N insert-unicode-char
zle -N insert-sudo
zle -N cd-parent
zle -N cd-undo

autoload -Uz add-zsh-hook cdr chpwd_recent_dirs compinit vcs_info zmv
compinit
add-zsh-hook chpwd chpwd_recent_dirs

# Completion
compdef gpg2=gpg
zstyle ':completion:*' use-cache on
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/5))numeric)'

# VCS Info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' formats '([%b]%u%c)'
zstyle ':vcs_info:*' actionformats '([%b|%a]%u%c)'

precmd() {
  vcs_info

  psvar=()
  psvar[1]="${${KEYMAP/vicmd/:}/(main|viins)/+}"
  [[ -n $vcs_info_msg_0_ ]] && psvar[2]="$vcs_info_msg_0_"

  case $TERM in
    termite|xterm*|rxvt*|(dt|k|E)term)
      {print -n '\e]0;'}
      ;;
    screen*|tmux*)
      {print -n '\e]2;'}
      ;;
  esac
  print -Pn "%n${SSH_CLIENT:+@%m}:%1~\a"
}

# Prompt
PROMPT="%B%F{yellow}%1v%h ["
PROMPT+="%b%F{yellow}%n%f"
PROMPT+="${SSH_CLIENT:+%B%F{yellow\}@%b%F{magenta\}%m}%f"
PROMPT+="%B%F{yellow}:%b%F{blue}%3~"
PROMPT+="%(2v. %B%F{blue}%2v%b%f.)"
PROMPT+="%B%F{yellow}]%(!.#.$)%f%b "
RPROMPT="%B%F{yellow}[%b%(0?.%F{green}%?.%F{red}%?)%f %B%F{yellow}%j %l]%b%f"

# Aliases
alias ls='ls --color=auto'
alias l.='ls --color=auto -d .*'
alias ll='ls --color=auto -l'
alias ll.='ls --color=auto -l -d .*'
alias view='vim -R'
alias bvim='vim -b'
alias bview='vim -Rb'
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
fi

function clear-clipboard {
  printf '\\n' | xclip -sel clip &>/dev/null
  gpaste-client empty &>/dev/null
  qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory &>/dev/null
}

function zman {
  PAGER="less -Rgis '+/^       $1'" man zshall
}

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
