umask 077

export LANG='en_US.UTF-8'
export LC_MEASUREMENT='en_CA.UTF-8'

export PATH=${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH
export MANPATH=${XDG_DATA_HOME:-$HOME/.local/share}/man:$MANPATH:

if hash gpgconf &>/dev/null && [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
elif [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

# If not running interactively, don't do anything
[[ $- =~ i ]] || return

set -o noclobber

shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s nocaseglob

bind Space:magic-space

HISTCONTROL="erasedups:ignoreboth"

export PAGER='less'
export LESS='-FRJgij4'
export LESSHISTFILE='-'

if hash nvim &>/dev/null; then
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

PROMPT_DIRTRIM=3
PROMPT_COMMAND="__precmd"
function __precmd {
  if [ "$(tput colors)" -gt 256 ] || [ "$COLORTERM" = "truecolor" ]; then
    local -A colors=(
      [default]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x65 0x7b 0x83)\\]"
      [user]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x29 0x80 0xb9)\\]"
      [idk1]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x34 0x49 0x5e)\\]"
      [cwd]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x1d 0x99 0xf3)\\]"
      [vcs]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x7f 0x8c 0x8d)\\]"
      [fail]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0xdc 0x32 0x2f)\\]"
      [reset]="\\[$(tput sgr0)\\]"
    )
  else
    local -A colors=(
      [default]="\\[$(tput setaf 7)\\]"
      [user]="\\[$(tput setaf 4)\\]"
      [cwd]="\\[$(tput setaf 6)\\]"
      [vcs]="\\[$(tput setaf 7)\\]"
      [fail]="\\[$(tput setaf 1)\\]"
      [reset]="\\[$(tput sgr0)\\]"
    )
  fi

  PS1="${colors["default"]}\\! ["
  PS1+="${colors["user"]}\\u"
  PS1+="${colors["default"]}:${colors[cwd]}\\w"
  if hash git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    PS1+=" ${colors["vcs"]}([$(git name-rev --name-only --no-undefined @)])"
  fi
  PS1+="${colors["default"]}]\\$ ${colors[reset]}"
}

alias hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" $(tput cols)) | tr " " ='
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
alias ln='ln -v'
alias rm='rm -Iv --preserve-root'
alias rename='rename -v'
alias mps='ps -u $USER'
alias ip='ip -c'
alias sudo='sudo '
alias sudop='sudo env PATH="$PATH" '
alias strace='strace -xy '
alias gdb='gdb -q '
alias vi='vim'
alias rvi='rvim'
if hash gpg2 &>/dev/null; then
  alias gpg='gpg2'
fi
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
if hash rg &>/dev/null; then
  alias rg='rg -S'
  alias grep='rg -S'
  function vim-grep {
    vim -q <(rg --vimgrep --no-heading -S "$@")
  }
elif hash ag &>/dev/null; then
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

if [ -r ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
