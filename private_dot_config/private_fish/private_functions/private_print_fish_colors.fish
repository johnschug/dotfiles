# Defined in /tmp/fish.670Lv0/print_fish_colors.fish @ line 1
function print_fish_colors --description 'Shows the various fish colors being used'
    set -l color_list (set -n | string match -re '^fish.*color')
    if string length -q "$color_list"
        set -l bclr (set_color normal)
        set -l bold (set_color --bold)
        set -l bad (set_color --bold white --background red)
        printf '\n| %-38s | %-38s |\n' Variable Definition
        echo '|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|'
        for var in $color_list
            set -l def $$var
            set -l clr (set_color $def 2>/dev/null)
            or begin
                printf "| %-38s | $bad%-38s$bclr |\n" $var "$def"
                continue
            end
            printf "| $clr%-38s$bclr | $bold%-38s$bclr |\n" $var "$def"
        end
        echo '|________________________________________|________________________________________|'\n
    end
end
