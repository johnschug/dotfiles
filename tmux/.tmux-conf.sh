#!/bin/sh
if command -v tput >/dev/null 2>&1; then
  colors=$(tput "-T${1:-$TERM}" colors)
else
  colors=
fi

if infocmp tmux >/dev/null 2>&1; then
  tmux set-option -g default-terminal tmux
else
  tmux set-option -g default-terminal screen
fi
if [ "$colors" -ge 16 ]; then
  if infocmp tmux-16color >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-16color
  else
    tmux set-option -g default-terminal screen-16color
  fi
fi
if [ "$colors" -ge 256 ]; then
  if infocmp tmux-256color >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-256color
  else
    tmux set-option -g default-terminal screen-256color
  fi
fi
if [ "$COLORTERM" = "truecolor" ] || [ "$colors" -gt 256 ]; then
  if infocmp tmux-direct >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-direct
  fi
  tmux set-options -sa ",${1:-$TERM}:RGB"
fi

if [ "$COLORTERM" = "truecolor" ] || [ "$colors" -gt 256 ] || { [ "$colors" -ge 256 ] && [ -n "$NOPALETTE" ]; }; then
  color0="#232629"
  color1="#eee8d5"
  color2="#31363b"
  color3="#93a1a1"
  color4="#586e75"
  color5="#657b83"
  color6="#1d99f3"
  color7="#2c3e50"
  search="#2980b9"
elif [ "$colors" -ge 16 ]; then
  color0="brightblack"
  color1="white"
  color2="black"
  color3="brightcyan"
  color4="brightgreen"
  color5="brightyellow"
  color6="blue"
  color7="brightmagenta"
  search="blue"
else
  color0="black"
  color1="white"
  color2="black"
  color3="white"
  color4="white"
  color5="white"
  color6="cyan"
  color7="blue"
  search="blue"
fi
tmux set-option -g message-style "bg=$color2,fg=$color3"
tmux set-option -g mode-style "fg=$search,reverse"
tmux set-option -g message-command-style "bg=$color2,fg=$color3"
tmux set-option -g status-left-style "bg=$color0,reverse"
tmux set-option -g status-right-style "bg=$color0,reverse"
tmux set-option -g status-style "bg=$color2,fg=$color3"
tmux set-option -wg window-style "bg=$color0,fg=$color1"
tmux set-option -wg window-status-current-style "bg=$color7,bold"

tmux set-option -g status-left "#[fg=$color4] #S #[fg=$color5] #{window_width}x#{window_height} "
tmux set-option -g status-right "#{?client_prefix,#[fg=$color6] P ,}${SSH_CONNECTION:+ #h }#[fg=$color5] #(cut -f1-4 -d' ' /proc/loadavg) #[fg=$color4] %F %R "
