# Auto-launch a multiplexer for new interactive shells.
#
# $MUX picks one:
#   tmux   (default) reattach to this directory's session, else the sesh picker
#   herdr            attach to the herdr server, which holds every workspace
#   none             plain shell
#
# Set it persistently with `export MUX=herdr` in shell/custom.sh, which ~/.zshrc
# sources before this file. For one shell: `MUX=herdr zsh`.
# (Still named tmux.sh because ~/.zshrc and the fish port source it by path.)
: ${MUX:=tmux}

# Skip if already inside a multiplexer. HERDR_ENV=1 marks a herdr pane;
# without this check every herdr pane would launch another multiplexer.
if [[ -n "$TMUX" ]] || [[ "$HERDR_ENV" == "1" ]]; then
    return
fi

# Skip in the VSCode terminal.
if [[ -n "$VSCODE_INJECTION" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
    return
fi

# Skip without a TTY.
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    return
fi

# Re-run this from a bare prompt, e.g. after the server died and the tab fell
# back to a shell. No-op inside a multiplexer.
tgo() { source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/tmux.sh" }

# ---- herdr ---- #
# One server holds every workspace, so there is nothing to pick here. Navigate
# inside herdr with prefix+w or the sesh picker on prefix+s.
# No exec: a server failure drops to this shell instead of closing the tab.
if [[ "$MUX" == "herdr" ]]; then
    if [[ -x "$(command -v herdr)" ]]; then
        herdr
        return
    fi
    echo "MUX=herdr but herdr is not installed; continuing with a plain shell." >&2
    return
fi

[[ "$MUX" == "tmux" ]] || return
[[ -x "$(command -v tmux)" ]] || return

# ---- Reattach to this directory's orphaned session ---- #
# Ghostty restores tabs by re-running the login shell in the tab's directory.
# Without this every restored tab lands on the picker instead of its session.
#
# Only DETACHED sessions count. Continuum restores sessions detached, so a real
# restore reattaches; but cmd+t inherits the current tab's directory, and that
# session is already attached, so a new tab correctly falls through to the picker.
matches=$(tmux list-sessions -F '#{session_path}	#{session_name}	#{session_attached}' 2>/dev/null \
    | awk -F'\t' -v d="$PWD" '$1 == d && $3 == 0 { print $2 }')
match_count=$(print -r -- "$matches" | grep -c .)
target=""
if (( match_count == 1 )); then
    target=$matches
elif (( match_count > 1 )); then
    # Several sessions share this path (e.g. "work" and "zi" both in ~/dev/zi).
    # Prefer the one named after the directory, else fall through to the picker.
    # tmux rewrites "." and ":" in session names, so normalise the basename.
    base=${PWD:t}
    base=${base//[.:]/_}
    target=$(print -r -- "$matches" | awk -v b="$base" '$0 == b { print; exit }')
fi
# No exec: if the tmux server dies the tab falls back to this shell with the
# same cwd. Reattach with `tgo`.
if [[ -n "$target" ]]; then
    tmux attach-session -t "$target"
    return
fi

# ---- sesh picker ---- #
if [[ -x "$(command -v sesh)" ]]; then
    # -t tmux sessions, -z zoxide directories, -c configured sessions
    selected=$(sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    if [[ -n "$selected" ]]; then
        sesh connect "$selected"
        return
    fi
    # Cancelled with Esc: continue to a normal shell.
fi
