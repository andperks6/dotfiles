# ---- Skip if tmux is not installed ---- #
if [[ ! -x "$(command -v tmux)" ]]; then
    return
fi

# ---- Skip if in VSCode terminal ---- #
if [[ -n "$VSCODE_INJECTION" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
    return
fi

# ---- Skip if already in tmux ---- #
if [[ -n "$TMUX" ]]; then
    return
fi

# ---- Skip if not a real terminal (no TTY) ---- #
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    return
fi

# Auto-launch sesh session picker with sesh
if [[ -x "$(command -v sesh)" ]]; then
    # Show session picker on terminal start
    selected=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')

    # Only connect if user selected something (not cancelled with Esc)
    if [[ -n "$selected" ]]; then
        exec sesh connect "$selected"
    fi
    # If cancelled, continue with normal shell
fi
