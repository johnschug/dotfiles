umask 077

set -q XDG_BIN_HOME
or set -l XDG_BIN_HOME "$HOME/.local/bin"
_path_add start "$XDG_BIN_HOME"

set -q XDG_DATA_HOME
or set -l XDG_DATA_HOME "$HOME/.local/share"
_path_add start "$XDG_DATA_HOME/man" MANPATH
_path_add end "" MANPATH

if test -d "$HOME/.cargo/bin"
    _path_add start "$HOME/.cargo/bin"
end
