umask 077

typeset -U fpath path manpath
fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/functions" $fpath)
path=("${XDG_BIN_HOME:-$HOME/.local/bin}" $path)
manpath=("${XDG_DATA_HOME:-$HOME/.local/share}/man" $manpath "")

export LANG='en_US.UTF-8'
export LC_MEASUREMENT='en_CA.UTF-8'

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

if (( $+commands[gpgconf] )) && [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
elif [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

if [ -r ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
