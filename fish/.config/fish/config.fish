if status is-login
    umask 077

    set -q XDG_BIN_HOME
    or set -l XDG_BIN_HOME $HOME/.local/bin
    fish_add_path -Pm $XDG_BIN_HOME

    set -q XDG_DATA_HOME
    or set -l XDG_DATA_HOME $HOME/.local/share
    _path_add start $XDG_DATA_HOME/man MANPATH
    _path_add end "" MANPATH

    fish_add_path -P $HOME/.cargo/bin

    if command -q gpgconf
        set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
        set -ge SSH_AGENT_PID
        set -ge SSH_ASKPASS
    else if test -S $HOME/.gnupg/S.gpg-agent.ssh
        set -gx SSH_AUTH_SOCK $HOME/.gnupg/S.gpg-agent.ssh
        set -ge SSH_AGENT_PID
        set -ge SSH_ASKPASS
    end
end

if status is-interactive
    # Environment Variables - Interactive Commands
    if type -q code
        set -gx EDITOR "code --wait"
        set -gx MERGE "$EDITOR --merge"

        alias edit 'code'
    else if command -sq nvim
        and not fish_is_root_user
        set -gx MANPAGER 'nvim +Man!'
        set -gx EDITOR nvim
        set -gx MERGE 'nvim -d'

        alias edit nvim
    else
        set -gx MANPAGER 'vim -M +MANPAGER -'
        set -gx EDITOR vim
        set -gx MERGE vimdiff

        alias edit vim
    end
    set -gx VISUAL $EDITOR

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
    alias vi vim
    if command -q nvim
        and not fish_is_root_user
        alias vim nvim
        alias rvim 'nvim -Z'
        alias view 'nvim -R'
        alias bvim 'nvim -b'
        alias bview 'nvim -Rb'
        alias vimdiff 'nvim -d'
    else
        alias view 'vim -R'
        alias bvim 'vim -b'
        alias bview 'vim -Rb'
    end
    if command -q findmnt
        alias lsmnt findmnt
    end
    if not command -q flatpak
        and command -q flatpak-spawn
        alias flatpak 'flatpak-spawn --host flatpak'
    end
    if command -q gpg2
        alias gpg gpg2
    end
    if not command -q scurl
        and command -q curl
        alias scurl "curl --tlsv1.2 --proto '=https'"
        alias scurl-download 'scurl --location --remote-name-all --remote-header-name'
    end
    if command -q rg
        alias rg 'rg -S'
        alias grep rg
        function vim-grep
            vim -q (command rg --vimgrep --no-heading -S $argv | psub)
        end
    else if command -q ag
        alias grep ag
        function vim-grep
            vim -q (ag --vimgrep $argv | psub)
        end
    else
        alias grep 'grep -ni --color=auto'
        function vim-grep
            vim -q (command grep -srnH $argv | psub)
        end
    end
    if command -q podman
        alias docker podman
    end
    if command -q systemctl
        alias userctl 'systemctl --user'
    end
    if command -q systemd-run
        alias scoped 'systemd-run --user --scope -qd '
    end

    if command -q gpg-connect-agent
        gpg-connect-agent updatestartuptty /bye &>/dev/null
    end
end

if test -r $__fish_config_dir/local.fish
    source $__fish_config_dir/local.fish
end
