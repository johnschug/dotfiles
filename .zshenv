umask 077

typeset -U path fpath
path=(~/.local/bin ~/bin $path)
fpath=(~/.local/share/zsh/functions ~/.zsh/functions $fpath)

export PAGER="less"
export LESS="-Rgi"
export LESSHISTFILE="-"
if hash nvim &>/dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi
export VISUAL="$EDITOR"
export SUDO_EDITOR="vim"

if [ -S "/run/user/$UID/gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
elif [ -S "/var/run/user/$UID/gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="/var/run/user/$UID/gnupg/S.gpg-agent.ssh"
elif [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
