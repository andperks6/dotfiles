#!/usr/bin/env bash
# Claude Code SessionStart hook.
#
# Records which Claude session is running in which tmux pane, so that
# resurrect-post-restore.sh can offer `claude --resume <id>` after a restore.
#
# Why this exists: tmux-resurrect never restores `claude` (it is not in
# @resurrect-default-processes), and the profile cannot be inferred from the
# directory -- e.g. this repo runs the *work* profile from ~/.config, which the
# cwd-based claude() wrapper in shell/aliases.sh would route to *personal*.
# So we capture CLAUDE_CONFIG_DIR from the live environment instead of guessing.
#
# Input: hook JSON on stdin (session_id, cwd).
# Output: one JSON line appended to $REGISTRY.

set -uo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-claude"
REGISTRY="$STATE_DIR/registry.jsonl"
LOG="$STATE_DIR/hook.log"

mkdir -p "$STATE_DIR" 2>/dev/null

# Always leave a trace. Every early return below is a silent no-op otherwise,
# which makes "the registry is empty" impossible to tell apart from "the hook
# never ran". Keep the log bounded.
log() {
  [ -f "$LOG" ] && [ "$(wc -l <"$LOG" 2>/dev/null || echo 0)" -gt 500 ] && \
    tail -n 200 "$LOG" >"$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG" 2>/dev/null
  printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$1" >>"$LOG" 2>/dev/null
}

# Not inside tmux -> nothing to record.
if [ -z "${TMUX_PANE:-}" ]; then
  log "skip: TMUX_PANE unset (not in a tmux pane, or env not inherited by hook)"
  exit 0
fi
if ! command -v tmux >/dev/null 2>&1; then
  log "skip: tmux not on PATH"
  exit 0
fi

payload="$(cat 2>/dev/null)"
if [ -z "$payload" ]; then
  log "skip: empty stdin payload"
  exit 0
fi

# Resolve the volatile pane id (%20) to the stable key resurrect saves panes
# under (session:window.pane), so lookups survive a restore.
pane_key="$(tmux display -p -t "$TMUX_PANE" \
  '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"
if [ -z "$pane_key" ]; then
  log "skip: could not resolve TMUX_PANE=$TMUX_PANE to a pane key"
  exit 0
fi

log "fire: pane=$pane_key config_dir=${CLAUDE_CONFIG_DIR:-<unset>}"

SESSION_PAYLOAD="$payload" \
PANE_KEY="$pane_key" \
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-}" \
python3 - "$REGISTRY" <<'PY' 2>/dev/null || exit 0
import json, os, sys, time

registry = sys.argv[1]
try:
    data = json.loads(os.environ.get("SESSION_PAYLOAD") or "{}")
except Exception:
    data = {}

session_id = data.get("session_id")
if not session_id:
    sys.exit(0)

record = {
    "pane":       os.environ["PANE_KEY"],
    "session_id": session_id,
    # Absolute path so the replayed command is profile-exact, not cwd-inferred.
    "config_dir": os.environ.get("CONFIG_DIR") or "",
    "cwd":        data.get("cwd") or os.getcwd(),
    "ts":         int(time.time()),
}
with open(registry, "a") as fh:
    fh.write(json.dumps(record) + "\n")
PY

exit 0
