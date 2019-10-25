if status is-login
    umask 077

    # These paths are added in /etc/profile on Fedora
    # which fish doesn't read... 🙁
    _path_add start /usr/local/bin
    _path_add end /usr/local/sbin
    _path_add end /usr/sbin

    set -q XDG_BIN_HOME
    or set -l XDG_BIN_HOME "$HOME/.local/bin"
    _path_add start "$XDG_BIN_HOME"

    set -q XDG_DATA_HOME
    or set -l XDG_DATA_HOME "$HOME/.local/share"
    _path_add start "$XDG_DATA_HOME/man" MANPATH
    _path_add end "" MANPATH

    _path_add start "$HOME/.cargo/bin"

    if command -sq gpgconf
        and test -S (gpgconf --list-dirs agent-ssh-socket)
        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
        set -ge SSH_AGENT_PID
        set -ge SSH_ASKPASS
    else if test -S "$HOME/.gnupg/S.gpg-agent.ssh"
        set -gx SSH_AUTH_SOCK "$HOME/.gnupg/S.gpg-agent.ssh"
        set -ge SSH_AGENT_PID
        set -ge SSH_ASKPASS
    end
end

if status is-interactive
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
    if command -sq findmnt
        alias lsmnt findmnt
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
end

if test -r "$__fish_config_dir/local.fish"
  source "$__fish_config_dir/local.fish"
end
