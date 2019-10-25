if not status is-login
    exit
end

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
