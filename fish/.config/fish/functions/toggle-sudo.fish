# Defined in /tmp/fish.XHeO9T/toggle-sudo.fish @ line 2
function toggle-sudo --description 'Toggle sudo use for the current commandline process'
    if commandline --paging-mode
        return
    end

    set -l cursor (commandline -C)
    set -l cmd (commandline -po)
    if test "$cmd[1]" = "sudo"
        commandline -p (string sub -s 6 "$cmd")
    else if test "$cmd[1]" != "su"
        commandline -p "sudo $cmd"
        commandline -C (math "$cursor + 5")
    end
end
