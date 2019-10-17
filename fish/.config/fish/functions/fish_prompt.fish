# Defined in /tmp/fish.59lFO2/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
	set -l last_status $status
    set -l color_cwd $fish_color_cwd
    set -l suffix '$'
    switch "$USER"
        case root toor
            if set -q fish_color_cwd_root
                set color_cwd $fish_color_cwd_root
            end
            set suffix '#'
    end

    set -l prompt_status
    if test "$last_status" -ne 0
        set prompt_status " "(set_color $fish_color_status)"[$last_status]"
    end

    set -g __fish_git_prompt_showdirtystate 1

    printf '%s%s%s%s%s%s ' (set_color $color_cwd) (prompt_pwd) (set_color normal) (__fish_vcs_prompt) "$prompt_status" "$suffix"
end
