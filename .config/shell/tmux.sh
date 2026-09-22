# Auto-launch a terminal multiplexer when a new interactive shell opens.
#
# Which one is chosen by $MUX:
#   tmux  (default) reattach to this directory's session, else the sesh picker
#   herdr           attach to the herdr server, which holds every workspace
#   none            plain shell
#
# Set it per-machine in shell/custom.sh, or for one shell with `MUX=herdr zsh`.
# (The file is still named tmux.sh because ~/.zshrc and the fish port source it
# by path; rename both together if tmux is eventually dropped.)
: ${MUX:=tmux}

# ---- Skip if already inside a multiplexer ---- #
# HERDR_ENV=1 marks a herdr-managed pane. Without this check every pane herdr
# spawns would launch a second multiplexer inside itself.
if [[ -n "$TMUX" ]] || [[ "$HERDR_ENV" == "1" ]]; then
    return
fi

# ---- Skip if in VSCode terminal ---- #
if [[ -n "$VSCODE_INJECTION" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
    return
fi

# ---- Skip if not a real terminal (no TTY) ---- #
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    return
fi

# Re-run this logic from a bare prompt (e.g. after the server crashed and this
# tab fell back to a shell). No-op inside a multiplexer.
tgo() { source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/tmux.sh" }

# ---- herdr ---- #
# One server holds every workspace, so there is nothing to pick here: attach
# and let herdr's own sidebar (prefix+w) and sesh picker (prefix+s) do the
# navigating. No exec, so a server failure drops to this shell rather than
# closing the tab.
if [[ "$MUX" == "herdr" ]]; then
    if [[ -x "$(command -v herdr)" ]]; then
        herdr
        return
    fi
    echo "MUX=herdr but herdr is not installed; falling through to a plain shell." >&2
    return
fi

[[ "$MUX" == "tmux" ]] || return

# ---- Skip if tmux is not installed ---- #
if [[ ! -x "$(command -v tmux)" ]]; then
    return
fi

# ---- Reattach to the orphaned session for this directory, if there is one ---- #
# Ghostty restores tabs by re-running the login shell with the tab's working
# directory. Without this, every restored tab lands on the picker instead of
# going back to the session it was showing.
#
# Only DETACHED sessions are considered. Continuum restores sessions detached,
# so a genuine restore still reattaches -- but "cmd+t" inherits the current
# tab's directory, and that session is already attached, so a new tab correctly
# falls through to the picker instead of cloning the session you are sitting in.
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
