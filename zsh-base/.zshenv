umask 077

typeset -U fpath path manpath
fpath=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/functions" $fpath)
path=("${XDG_BIN_HOME:-$HOME/.local/bin}" $path)
manpath=("${XDG_DATA_HOME:-$HOME/.local/share}/man" $manpath "")
export MANPATH

export LANG='en_US.UTF-8'
export LC_MEASUREMENT='en_CA.UTF-8'

if (( $+commands[gpgconf] )) && [ -S "$(gpgconf --list-dirs agent-ssh-socket)" ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  unset SSH_AGENT_PID
  unset SSH_ASKPASS
elif [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
  unset SSH_AGENT_PID
  unset SSH_ASKPASS
fi

if [ -r ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
