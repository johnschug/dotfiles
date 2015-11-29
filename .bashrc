# .bashrc

umask 077

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

[[ $- =~ i ]] || return

unset HISTFILE

# Start tmux
if hash tmux &> /dev/null; then
  if [ -z "$TMUX" ]; then
    exec tmux new -A -s "default"
  fi
fi

# Prompt
PROMPT_DIRTRIM=3
Color_Off='\[\e[0m\]'
White='\[\e[1;37m\]'
Blue='\[\e[0;34m\]'
BlueBold='\[\e[1;34m\]'
Magenta='\[\e[0;35m\]'
Yellow='\[\e[0;33m\]'
YellowBold='\[\e[1;33m\]'
if [ -f ~/.git-prompt.sh ]; then
  export GIT_PS1_SHOWDIRTYSTATE=1
  source ~/.git-prompt.sh
  export PS1="${YellowBold}\# [${Yellow}\u${YellowBold}@${Magenta}\h ${BlueBold}\
\$(__git_ps1 '([%s]) ')${Blue}\w${YellowBold}]\\$ ${White}"
else
  export PS1="${YellowBold}\# [${Yellow}\u${YellowBold}@${Magenta}\h \
${Blue}\w${YellowBold}]\\$ ${White}"
fi
trap "echo -ne '\e[0m'" DEBUG

if [ -f ~/.bashrc.local ]; then
  source ~/.bashrc.local
fi
