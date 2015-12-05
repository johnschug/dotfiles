# Start tmux
if hash tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    exec tmux new -A -s default
  fi
fi

# Options
setopt auto_cd
setopt complete_aliases
setopt correct
setopt extended_glob
setopt glob_complete
setopt interactive_comments
setopt notify

# Bindings
export KEYTIMEOUT=5
bindkey -v
bindkey '^f' edit-command-line
bindkey '^k' insert-composed-char
bindkey '^v' insert-unicode-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[s' insert-sudo
bindkey -M vicmd 'v' edit-command-line
bindkey -M vicmd 'q' push-input
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo
bindkey -M vicmd '~' vi-swap-case
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

autoload -Uz edit-command-line insert-composed-char insert-unicode-char
function insert-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}

zle -N edit-command-line
zle -N insert-composed-char
zle -N insert-unicode-char
zle -N insert-sudo

autoload -Uz add-zsh-hook cdr chpwd_recent_dirs colors compinit vcs_info zmv
compinit
colors
add-zsh-hook chpwd chpwd_recent_dirs

# Completion
compdef gpg2=gpg
zstyle ':completion:*' use-cache on
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' '+l:|=* r:|=*'
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

# VI mode indicator
function zle-line-init zle-keymap-select zle-line-finish {
  psvar[1]="${${KEYMAP/vicmd/:}/(main|viins)/+}"
  zle reset-prompt
  zle -R
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

precmd() {
  case $TERM in
    xterm*)
      {print -Pn '\e]0;%n@%m:%1~\a'}
      ;;
    screen* | tmux*)
      {print -Pn '\e]2;%n@%m:%1~\a'}
      ;;
  esac
  vcs_info

  psvar=()
  psvar[1]="${${KEYMAP/vicmd/:}/(main|viins)/+}"
  [[ -n $vcs_info_msg_0_ ]] && psvar[2]="$vcs_info_msg_0_"
}

# Prompt
PROMPT="%{$fg_bold[yellow]%}%1v%h [%b%F{yellow}%n%f%{$fg_bold[yellow]%}@%b%F{magenta}%m%f \
%(2v.%{$fg_bold[blue]%}%2v%b .)%F{blue}%3~%{$fg_bold[yellow]%}]%(!.#.$)%b%f "
RPROMPT="%{$fg_bold[yellow]%}[%b%(0?.%F{green}%?.%F{red}%?)%f %{$fg_bold[yellow]%}%j %l]%b%f"

function clear-clipboard {
  printf '\\n' | xclip -sel clip &>/dev/null
  gpaste-client empty &>/dev/null
  qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory &>/dev/null
}

function zman {
  PAGER="less -g -s '+/^       $1'" man zshall
}

# Aliases
alias ls='ls --color=auto'
alias l.='ls --color=auto -d .*'
alias ll='ls --color=auto -l'
alias ll.='ls --color=auto -l -d .*'
alias less='less -Rgi'
alias view='vim -R'
alias bvim='vim -b'
alias bview='vim -Rb'
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

if [ -f ~/.zsh/plugins/plugins.zsh ]; then
  source ~/.zsh/plugins/plugins.zsh
fi

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
