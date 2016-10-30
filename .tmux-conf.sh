#!/bin/sh

COLORS="$(tput colors)"
if [ "$COLORS" -gt 256 ] || [ "$COLORTERM" = "truecolor" ]; then
    tmux set -ga terminal-overrides ",xterm-256color:Tc,screen-256color:Tc,tmux-256color:Tc"
fi

if [ "$COLORS" -ge 256 ]; then
  if infocmp tmux-256color >/dev/null 2>&1; then
    tmux set -g default-terminal tmux-256color
  else
    tmux set -g default-terminal screen-256color
  fi
elif [ "$COLORS" -ge 16 ]; then
  if infocmp tmux-16color >/dev/null 2>&1; then
    tmux set -g default-terminal tmux-16color
  else
    tmux set -g default-terminal screen-16color
  fi
else
  if infocmp tmux >/dev/null 2>&1; then
    tmux set -g default-terminal tmux
  else
    tmux set -g default-terminal screen
  fi
fi

VERSION="$(tmux -V | cut -d' ' -f2)"
 if [ "$COLORS" -gt 256 ] || [ "$COLORTERM" = "truecolor" ] &&
   [ "$(printf '2.3\n%s\n' "$VERSION" | sort -V | head -n1)" = "2.3" ]; then
   COLOR0="#232629"
   COLOR1="#eee8d5"
   COLOR2="#31363b"
   COLOR3="#93a1a1"
   COLOR4="#586e75"
   COLOR5="#657b83"
   COLOR6="#2c3e50"
elif [ -n "$TMUX_NOPALETTE" ]; then
  COLOR0="colour235"
  COLOR1="colour255"
  COLOR2="colour237"
  COLOR3="colour247"
  COLOR4="colour241"
  COLOR5="colour243"
  COLOR6="colour24"
elif [ "$COLORS" -ge 16 ]; then
  COLOR0="brightblack"
  COLOR1="white"
  COLOR2="black"
  COLOR3="brightcyan"
  COLOR4="brightgreen"
  COLOR5="brightyellow"
  COLOR6="brightmagenta"
else
  COLOR0="black"
  COLOR1="white"
  COLOR2="black"
  COLOR3="white"
  COLOR4="white"
  COLOR5="white"
  COLOR6="blue"
fi
tmux set -g window-style "bg=${COLOR0},fg=${COLOR1}"
tmux set -g message-style "bg=${COLOR2},fg=${COLOR3}"
tmux set -g message-command-style "bg=${COLOR2},fg=${COLOR3}"
tmux set -g status-style "bg=${COLOR2},fg=${COLOR3}"
tmux set -g status-left "#[bg=${COLOR4},fg=${COLOR0}] #S #[bg=${COLOR5}] #{session_width}x#{session_height} "
tmux set -g status-right "#[bg=${COLOR5},fg=${COLOR0}] #(cut -f1-4 -d' ' /proc/loadavg) #[bg=${COLOR4}] %F %R "
tmux set -g window-status-format " #I) #T (#W) "
tmux set -g window-status-current-format "#[bg=${COLOR6},bold] #I) #T "
