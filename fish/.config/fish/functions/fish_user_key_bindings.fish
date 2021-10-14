function fish_user_key_bindings
    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cp history-prefix-search-backward
    bind -M insert \cn history-prefix-search-forward
    bind -M insert \ep history-token-search-backward
    bind -M insert \en history-token-search-forward
    bind -M insert \es toggle-sudo
    bind -M insert \ct 'cd ../; commandline -f repaint'
    bind -M insert \co 'prevd; commandline -f repaint'
end
