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

# Re-run the reattach/picker logic from a bare prompt (e.g. after the tmux
# server crashed and this tab fell back to a shell). No-op inside tmux.
tgo() { source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/tmux.sh" }

# ---- Reattach to the orphaned session for this directory, if there is one ---- #
# Ghostty restores tabs by re-running the login shell with the tab's working
# directory. Without this, every restored tab lands on the picker instead of
# going back to the session it was showing.
#
# Only DETACHED sessions are considered. Continuum restores sessions detached,
# so a genuine restore still reattaches -- but "cmd+t" inherits the current
# tab's directory, and that session is already attached, so a new tab correctly
# falls through to the picker instead of cloning the session you are sitting in.
if [[ -x "$(command -v tmux)" ]]; then
    matches=$(tmux list-sessions -F '#{session_path}	#{session_name}	#{session_attached}' 2>/dev/null \
        | awk -F'\t' -v d="$PWD" '$1 == d && $3 == 0 { print $2 }')
    match_count=$(print -r -- "$matches" | grep -c .)
    target=""
    if (( match_count == 1 )); then
        target=$matches
    elif (( match_count > 1 )); then
        # Several sessions share this path (e.g. both "work" and "zi" sit in
        # ~/dev/zi). Prefer the one named after the directory; if that is still
        # ambiguous, fall through to the picker rather than guessing wrong.
        # tmux rewrites "." and ":" in session names, so normalise the basename.
        base=${PWD:t}
        base=${base//[.:]/_}
        target=$(print -r -- "$matches" | awk -v b="$base" '$0 == b { print; exit }')
    fi
    # No exec: if the tmux server dies, the tab falls back to this shell
    # (same cwd, tab order intact) instead of closing. Reattach with `tgo`.
    if [[ -n "$target" ]]; then
        tmux attach-session -t "$target"
        return
    fi
fi

# Auto-launch sesh session picker with sesh
if [[ -x "$(command -v sesh)" ]]; then
    # Show session picker on terminal start
    # -t: tmux sessions, -z: zoxide directories, -c: config sessions
    selected=$(sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')

    # Only connect if user selected something (not cancelled with Esc)
    if [[ -n "$selected" ]]; then
        sesh connect "$selected"
        return
    fi
    # If cancelled, continue with normal shell
fi
