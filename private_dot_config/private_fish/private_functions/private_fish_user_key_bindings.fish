function fish_user_key_bindings
    bind -M insert ctrl-a beginning-of-line
    bind -M insert ctrl-e end-of-line
    bind -M insert alt-k history-token-search-backward
    bind -M insert alt-j history-token-search-forward
    bind -M insert alt-K history-prefix-search-backward
    bind -M insert alt-J history-prefix-search-forward
    bind -M insert ctrl-t 'cd ../; commandline -f repaint'
    bind -M insert ctrl-o 'prevd; commandline -f repaint'
end
