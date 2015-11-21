# Start tmux
if hash tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    exec tmux new -A -s "default"
  fi
fi

# Bindings
export KEYTIMEOUT=5
bindkey -v
bindkey "^k" insert-composed-char
bindkey "^v" insert-unicode-char
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
bindkey "^[s" insert-sudo
bindkey -M vicmd "q" push-line
bindkey -M vicmd "u" undo
bindkey -M vicmd "^r" redo
bindkey -M vicmd "~" vi-swap-case
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward

autoload -Uz insert-composed-char insert-unicode-char
function insert-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}

zle -N insert-composed-char
zle -N insert-unicode-char
zle -N insert-sudo

# Aliases
alias ls="ls --color=auto"
alias less="less -R"
alias view="vim -R"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias cp="cp --reflink=auto --sparse=always"
alias cpv="rsync -pogh --progress"
alias zcp="zmv -C"
alias zln="zmv -L"

# Options
setopt autocd
setopt correct
setopt extendedglob
setopt glob_complete
setopt notify
setopt completealiases

autoload -Uz compinit colors vcs_info zmv chpwd_recent_dirs cdr add-zsh-hook
compinit
colors
add-zsh-hook chpwd chpwd_recent_dirs

# Completion
compdef gpg2=gpg
zstyle ':completion:*' use-cache on
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select=long
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
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
    screen*)
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
  echo "" | xclip -sel clip &>/dev/null
  gpaste empty &>/dev/null
  qdbus org.kde.klipper /klipper org.kde.klipper.klipper.clearClipboardHistory &>/dev/null
}

function mkcd {
  mkdir -p $1 && cd $1
}

function zman {
  PAGER="less -g -s '+/^       "$1"'" man zshall
}

if [ -f ~/.zsh/plugins/plugins.zsh ]; then
  source ~/.zsh/plugins/plugins.zsh
fi

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi
