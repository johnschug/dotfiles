if not status is-interactive
    exit
end

# Start tmux
if command -sq tmux
    and not set -q TMUX
    if command -sq systemd-run
        systemd-run --scope --user -qG tmux new -d -s DEFAULT >/dev/null 2>&1
    end
    exec tmux new -A -s DEFAULT
end

# Environment Variables - Interactive Commands
set -gx PAGER less
set -gx LESS '-FRJgij4'
set -gx LESSHISTFILE '-'
if command -sq nvim
    set -gx MANPAGER "env MANPATH=\"$MANPATH\" nvim -c 'set ft=man' -"
    set -gx EDITOR nvim
    set -gx MERGE 'nvim -d'
else
    set -gx MANPAGER "env MANPATH=\"$MANPATH\" vim +MANPAGER -"
    set -gx EDITOR vim
    set -gx MERGE vimdiff
end
set -gx VISUAL "$EDITOR"
set -gx SUDO_EDITOR vim

# Key Bindings
set -g fish_key_bindings fish_vi_key_bindings

# Aliases
alias ls 'ls --color=auto'
alias l. "ls --color=auto -AI '[^.]*'"
alias ll 'ls --color=auto -l'
alias ll. "ls --color=auto -lAI '[^.]*'"
alias info 'info --vi-keys'
alias chown 'chown -c --preserve-root'
alias chmod 'chmod -c --preserve-root'
alias mkdir 'mkdir -pv'
alias cp 'cp -iv --reflink=auto --sparse=always'
alias mv 'mv -iv'
alias ln 'ln -iv'
alias rm 'rm -Iv --preserve-root --one-file-system'
alias rename 'rename -v'
alias mps 'ps -u $USER'
alias ip 'ip -c'
alias sudop 'sudo env PATH="$PATH" '
alias strace 'strace -xy '
alias gdb 'gdb -q '
alias vi 'vim'
if command -sq nvim
    alias vim 'nvim'
    alias rvim 'nvim -Z'
    alias view 'nvim -R'
    alias bvim 'nvim -b'
    alias bview 'nvim -Rb'
else
    alias view 'vim -R'
    alias bvim 'vim -b'
    alias bview 'vim -Rb'
end
if command -sq gpg2
    alias gpg gpg2
end
if not command -sq scurl
    and command -sq curl
    alias scurl "curl --tlsv1.2 --proto '=https'"
    alias scurl-download 'scurl --location --remote-name-all --remote-header-name'
end
if command -sq rg
    alias rg 'rg -S'
    alias grep rg
    function vim-grep
        vim -q (rg --vimgrep --no-heading -S $argv | psub)
    end
else if command -sq ag
    alias grep ag
    function vim-grep
        vim -q (ag --vimgrep $argv | psub)
    end
else
    alias grep 'grep -ni --color=auto'
    function vim-grep
        vim -q (grep -srnH $argv | psub)
    end
end
if command -sq podman
    alias docker podman
end
if command -sq systemd-run
    alias scoped 'systemd-run --user --scope -qd '
end
#alias hr='printf $(printf "\e[$(shuf -i 91-97 -n 1);1m%%%ds\e[0m\n" ${terminfo[cols]}) | tr " " ='
