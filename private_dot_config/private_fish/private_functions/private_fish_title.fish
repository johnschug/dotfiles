# Defined in /tmp/fish.hA9axS/fish_title.fish @ line 2
function fish_title
    set -q SSH_TTY
    and set -l ssh '@'(prompt_hostname | string sub -l 10 | string collect)
    printf '%s%s:%s' "$USER" "$ssh" (prompt_pwd -d 1 -D 1)
end
