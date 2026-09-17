#!/usr/bin/env bash
# tmux-resurrect @resurrect-hook-post-save-all
#
# tmux-resurrect keeps every layout snapshot (tmux_resurrect_<ts>.txt) but only
# ONE pane_contents.tar.gz, overwritten on every save. After a crash, continuum
# auto-saves the freshly-restored (empty) state within minutes and the pre-crash
# scrollback is gone -- which is exactly what happened on 2026-07-27.
#
# This pairs each archive with its layout file so old scrollback survives.
# To roll back to a specific point in time:
#   cd ~/.local/share/tmux/resurrect
#   cp pane_contents_<ts>.tar.gz pane_contents.tar.gz
#   ln -sf tmux_resurrect_<ts>.txt last

set -uo pipefail

DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
ARCHIVE="$DIR/pane_contents.tar.gz"
KEEP=24

[ -f "$ARCHIVE" ] || exit 0

# Derive the timestamp from the layout file this save just wrote.
target="$(readlink "$DIR/last" 2>/dev/null)"
ts="${target#tmux_resurrect_}"
ts="${ts%.txt}"
[ -n "$ts" ] || exit 0

paired="$DIR/pane_contents_${ts}.tar.gz"
[ -e "$paired" ] || cp -p "$ARCHIVE" "$paired" 2>/dev/null || exit 0

# Prune oldest paired archives; the numbered layout files are left alone.
count="$(find "$DIR" -maxdepth 1 -name 'pane_contents_*.tar.gz' | wc -l | tr -d ' ')"
if [ "${count:-0}" -gt "$KEEP" ]; then
  find "$DIR" -maxdepth 1 -name 'pane_contents_*.tar.gz' -print0 2>/dev/null \
    | xargs -0 ls -1t 2>/dev/null \
    | tail -n "+$((KEEP + 1))" \
    | while IFS= read -r old; do rm -f -- "$old"; done
fi

exit 0
