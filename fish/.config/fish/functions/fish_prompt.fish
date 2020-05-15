# Defined in /tmp/fish.jBE68f/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
    set -l last_status $status
    set -l color_normal $fish_color_normal
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
    set -g __fish_git_prompt_showuntrackedfiles 1
    set -g __fish_git_prompt_showupstream informative
    set -g __fish_git_prompt_describe_style branch
    set -g __fish_git_prompt_char_untrackedfiles '?'

    printf '%s%s%s%s%s%s ' (set_color $color_cwd) (prompt_pwd) (set_color $color_normal) (__fish_vcs_prompt) "$prompt_status" "$suffix"
end
