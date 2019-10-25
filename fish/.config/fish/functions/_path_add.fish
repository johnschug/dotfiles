function _path_add --description 'Add directory to PATH' --argument pos path
    set -q argv[3]
    and set -l pathvar $argv[3]
    or set -l pathvar PATH

    if not contains -- "$path" $$pathvar
        switch $pos
            case start
                set -gxp -- "$pathvar" "$path"
            case end
                set -gxa -- "$pathvar" "$path"
        end
    end
end
