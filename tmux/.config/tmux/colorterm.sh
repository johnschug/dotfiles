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
  tmux set-option -sa terminal-features ",${1:-$TERM}:RGB"
fi

if [ "$colors" -lt 16 ]; then
  bg="black"
  fg="white"
  status="$bg"
  normal="$fg"
  active="green"
  search="blue"
  outer="white"
  inner="white"
elif [ "$colors" -lt 256 ]; then
  bg="brightblack"
  fg="white"
  status="$bg"
  normal="$fg"
  active="green"
  search="blue"
  outer="brightgreen"
  inner="brightyellow"
else
  bg="#232629"
  fg="#eef0f1"
  status="$bg"
  normal="#95a5a6"
  active="#27ae60"
  search="#1d99f3"
  outer="#586e75"
  inner="#657b83"
fi
tmux set-option -g mode-style "fg=$search,reverse"
tmux set-option -g message-style "bg=$status,fg=$normal"
tmux set-option -g message-command-style "bg=$status,fg=$normal"
tmux set-option -g status-left-style "bg=$bg,reverse"
tmux set-option -g status-right-style "bg=$bg,reverse"
tmux set-option -g status-style "bg=$status,fg=$normal"
tmux set-option -wg pane-border-style "bg=$bg"
tmux set-option -wg pane-active-border-style "bg=$bg,fg=$active"
tmux set-option -wg window-style "bg=$bg,fg=$fg"
tmux set-option -wg window-status-current-style "fg=$active,reverse"

tmux set-option -g status-left "#[fg=$outer] #S #[fg=$inner] #{window_width}x#{window_height} "
tmux set-option -g status-right "#{?client_prefix,#[fg=$search] P ,}${SSH_CONNECTION:+ #h }#[fg=$inner] #(cut -f1-4 -d' ' /proc/loadavg) #[fg=$outer] %F %R "
