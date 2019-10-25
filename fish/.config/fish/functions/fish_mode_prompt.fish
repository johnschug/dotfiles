# Defined in /tmp/fish.n3trf7/fish_mode_prompt.fish @ line 2
function fish_mode_prompt --description 'Displays the current mode'
    set_color $fish_color_normal
    switch $fish_bind_mode
        case default
            echo -n ':'
        case insert
            echo -n '+'
        case replace_one
            echo -n '='
        case visual
            echo -n '*'
        case '*'
            echo -n '?'
    end
end
