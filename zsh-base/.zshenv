umask 077

typeset -U fpath path manpath
fpath=("${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/functions" $fpath)
path=(~/.local/bin $path)
manpath=("${XDG_DATA_HOME:-${HOME}/.local/share}/man" $manpath "")

export PAGER="less"
export LESS="-Rgi"
export LESSHISTFILE="-"
if hash nvim &>/dev/null; then
  export MANPAGER="env MANPATH=\"${MANPATH}\" nvim -c 'set ft=man' -"
  export EDITOR="nvim"
else
  export MANPAGER="env MAN_PN=1 MANPATH=\"${MANPATH}\" vim -RM +MANPAGER -"
  export EDITOR="vim"
fi
export VISUAL="$EDITOR"
export SUDO_EDITOR="vim"

if [ -S "/run/user/$UID/gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
elif [ -S "/var/run/user/$UID/gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="/var/run/user/$UID/gnupg/S.gpg-agent.ssh"
elif [ -S "${HOME}/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
