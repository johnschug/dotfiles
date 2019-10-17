# Defined in /tmp/fish.Px6O3w/fish_user_key_bindings.fish @ line 2
function fish_user_key_bindings
	bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert \es toggle-sudo
    bind -M insert \ct 'cd ../; commandline -f repaint'
    bind -M insert \co 'prevd; commandline -f repaint'
end
