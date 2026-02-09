if status is-interactive
    set -gx SSH_AGENT_DIR "$HOME/.ssh/agent"
    set -gx SSH_AUTH_SOCK "$SSH_AGENT_DIR/ssh-agent.sock"

    if not test -d "$SSH_AGENT_DIR"
        mkdir -p "$SSH_AGENT_DIR"
        chmod 700 "$SSH_AGENT_DIR"
    end

    set -l need_agent 0
    if test -S "$SSH_AUTH_SOCK"
        ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            set need_agent 1
        end
    else
        set need_agent 1
    end

    if test $need_agent -eq 1
        if test -S "$SSH_AUTH_SOCK"
            rm -f "$SSH_AUTH_SOCK"
        end
        eval (ssh-agent -c -a "$SSH_AUTH_SOCK") >/dev/null
    end

    ssh-add -l >/dev/null 2>&1
    if test $status -eq 1
        ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
    end
end
