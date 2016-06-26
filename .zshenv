umask 077

typeset -U path fpath
path=(~/.local/bin ~/bin $path)
fpath=(~/.zsh/functions $fpath)

export EDITOR="vim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-Rgi"

# Start gpg-agent
if hash gpg-connect-agent &>/dev/null; then
  gpg-connect-agent /bye &>/dev/null
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
