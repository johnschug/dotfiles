# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export PATH=$PATH:$HOME/bin:$HOME/.local/bin
export CLASSPATH="./:$HOME/lib/*:$HOME/.local/lib/*:${CLASSPATH}"
export EDITOR="vim"
export PAGER="less -R"

# Start gpg-agent
if hash gpg-connect-agent &> /dev/null; then
  gpg-connect-agent /bye
  export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi
