if [ -r /etc/bashrc ]; then
  source /etc/bashrc
fi

umask 077

export LANG='en_US.UTF-8'
export LC_MEASUREMENT='en_CA.UTF-8'

export PATH=${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH
export MANPATH=${XDG_DATA_HOME:-$HOME/.local/share}/man:$MANPATH:

if hash gpgconf &>/dev/null && [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  unset SSH_AGENT_PID
  unset SSH_ASKPASS
elif [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
  unset SSH_AGENT_PID
  unset SSH_ASKPASS
fi

# If not running interactively, don't do anything
[[ $- =~ i ]] || return

# Start tmux
if hash tmux &>/dev/null && [ -z "$TMUX" ]; then
  if [ -n "$SSH_CONNECTION" ]; then
    read -rsn 1 -p 'Press any key to continue...'
  fi
  if hash systemd-run &>/dev/null; then
    systemd-run --scope --user -qG tmux new -d -s DEFAULT &>/dev/null
  fi
  exec tmux new -A -s DEFAULT
fi

# Environment Variables - Interactive Commands
export PAGER='less'
export LESS='-FRJgij4'
export LESSHISTFILE='-'

if hash nvim &>/dev/null; then
  export MANPAGER="env MANPATH=\"$MANPATH\" nvim +Man!"
  export EDITOR='nvim'
  export MERGE='nvim -d'
else
  export MANPAGER="env MAN_PN=1 MANPATH=\"$MANPATH\" vim -M +MANPAGER -"
  export EDITOR='vim'
  export MERGE='vimdiff'
fi

export VISUAL="$EDITOR"
export SUDO_EDITOR='vim'

# Shell Options
set -o noclobber

shopt -s autocd
shopt -s cdspell
shopt -s checkhash
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dirspell
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s nocaseglob
shopt -s progcomp

HISTTIMEFORMAT='%F %T '
HISTCONTROL='erasedups:ignoreboth'

# Bindings
function _toggle-sudo {
  if [[ ! "$READLINE_LINE" =~ ^su(do|)\  ]]; then
    READLINE_LINE="sudo $READLINE_LINE"
    (( READLINE_POINT += 5 ))
  elif [[ "$READLINE_LINE" =~ ^sudo\  ]]; then
    READLINE_LINE=${READLINE_LINE#"sudo "}
    (( READLINE_POINT -= 5 ))
  fi
}

bind Space:magic-space
bind -m vi-insert -x '"\es":"_toggle-sudo"'

# Prompt
PROMPT_DIRTRIM=3
PROMPT_COMMAND="__prompt_cmd"
function __prompt_cmd {
  local last_status=$?
  if [ "$(tput colors)" -gt 256 ] || [ "$COLORTERM" = "truecolor" ]; then
    local -A colors=(
      [default]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x65 0x7b 0x83)\\]"
      [user]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x29 0x80 0xb9)\\]"
      [cwd]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x3d 0xae 0xe9)\\]"
      [vcs]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0x7f 0x8c 0x8d)\\]"
      [fail]="\\[$(printf '\e[38;2;%lu;%lu;%lum' 0xda 0x44 0x53)\\]"
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

  printf '%s%s:%s%s' "$(tput tsl)" "$USER" "${PWD/#$HOME/~}" "$(tput fsl)"

  PS1="${colors[cwd]}\\w"
  if hash git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    PS1+=" ${colors["vcs"]}([$(git name-rev --name-only --no-undefined @)])"
  fi
  if [ "$last_status" -ne 0 ]; then
    PS1+=" ${colors["fail"]}[$last_status]"
  fi
  PS1+="${colors["default"]}\\$ ${colors[reset]}"
}

# Aliases
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
if hash gpg2 &>/dev/null; then
  alias gpg='gpg2'
fi
if ! hash open &>/dev/null; then
  alias open='xdg-open'
fi
if ! hash scurl &>/dev/null && hash curl &>/dev/null; then
  alias scurl="curl --tlsv1.2 --proto '=https'"
  alias scurl-download='scurl --location --remote-name-all --remote-header-name'
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
if hash podman &>/dev/null; then
  alias docker='podman'
fi
if hash systemd-run &>/dev/null; then
  alias scoped='systemd-run --user --scope -qd '
fi

# Source host specific configuration
if [ -r ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
