umask 077

typeset -U fpath
if [ -d ~/.zsh/functions ]; then
  fpath+=(~/.zsh/functions)
fi

typeset -U path
path+=("$HOME/bin" "$HOME/.local/bin")

typeset -U manpath
manpath+=("$HOME/.local/share/man")

export -TU CLASSPATH classpath
classpath+=("$HOME/lib/*" "$HOME/.local/lib/*" "./")

export EDITOR="vim"
export PAGER="less -R"

# Start gpg-agent
if hash gpg-connect-agent &>/dev/null; then
  gpg-connect-agent /bye &>/dev/null
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi

if [ -f ~/.zshenv.local ]; then
  source ~/.zshenv.local
fi
