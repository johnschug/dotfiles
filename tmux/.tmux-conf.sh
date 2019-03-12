#!/bin/sh
if command -v tput >/dev/null 2>&1; then
  COLORS=$(tput "-T${1:-$TERM}" colors)
else
  COLORS=
fi

if infocmp tmux >/dev/null 2>&1; then
  tmux set-option -g default-terminal tmux
else
  tmux set-option -g default-terminal screen
fi
if [ "$COLORS" -ge 16 ]; then
  if infocmp tmux-16color >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-16color
  else
    tmux set-option -g default-terminal screen-16color
  fi
fi
if [ "$COLORS" -ge 256 ]; then
  if infocmp tmux-256color >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-256color
  else
    tmux set-option -g default-terminal screen-256color
  fi
fi
if [ "$COLORTERM" = "truecolor" ] || [ "$COLORS" -gt 256 ]; then
  if infocmp tmux-direct >/dev/null 2>&1; then
    tmux set-option -g default-terminal tmux-direct
  fi
fi

if [ "$COLORTERM" = "truecolor" ] || [ "$COLORS" -gt 256 ] || { [ "$COLORS" -ge 256 ] && [ -n "$NOPALETTE" ]; }; then
  if [ "$COLORTERM" = "truecolor" ] && ! [ "$COLORS" -gt 256 ]; then
    tmux set-option -sa terminal-overrides ",${1:-$TERM}:RGB"
  fi
  COLOR0="#232629"
  COLOR1="#eee8d5"
  COLOR2="#31363b"
  COLOR3="#93a1a1"
  COLOR4="#586e75"
  COLOR5="#657b83"
  COLOR6="#1d99f3"
  COLOR7="#2c3e50"
  SEARCH="#2980b9"
elif [ "$COLORS" -ge 16 ]; then
  COLOR0="brightblack"
  COLOR1="white"
  COLOR2="black"
  COLOR3="brightcyan"
  COLOR4="brightgreen"
  COLOR5="brightyellow"
  COLOR6="blue"
  COLOR7="brightmagenta"
  SEARCH="blue"
else
  COLOR0="black"
  COLOR1="white"
  COLOR2="black"
  COLOR3="white"
  COLOR4="white"
  COLOR5="white"
  COLOR6="cyan"
  COLOR7="blue"
  SEARCH="blue"
fi
tmux set-option -wg window-style "bg=$COLOR0,fg=$COLOR1"
tmux set-option -g message-style "bg=$COLOR2,fg=$COLOR3"
tmux set-option -g mode-style "fg=$SEARCH,reverse"
tmux set-option -g message-command-style "bg=$COLOR2,fg=$COLOR3"
tmux set-option -g status-style "bg=$COLOR2,fg=$COLOR3"
tmux set-option -g status-left-style "bg=$COLOR0,reverse"
tmux set-option -g status-right-style "bg=$COLOR0,reverse"
tmux set-option -g status-left "#[fg=$COLOR4] #S #[fg=$COLOR5] #{session_width}x#{session_height} "
tmux set-option -g status-right "#{?client_prefix,#[fg=$COLOR6] P ,}#[fg=$COLOR5] #(cut -f1-4 -d' ' /proc/loadavg) #[fg=$COLOR4] %F %R "
tmux set-option -wg window-status-current-style "bg=$COLOR7,bold"
