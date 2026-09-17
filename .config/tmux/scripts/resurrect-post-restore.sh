#!/usr/bin/env bash
# tmux-resurrect @resurrect-hook-post-restore-all
#
# tmux-resurrect restores layouts and cwds but never restores `claude`, so panes
# that held a Claude session come back as bare shells. This walks the panes that
# were recorded by claude-pane-registry.sh and pre-types the matching
# `claude --resume` command into each one.
#
# Default is deliberately NOT to press Enter: restoring ~20 sessions would
# launch 20 Claude instances at once. The command is left on the prompt for you
# to accept per pane. Opt in to auto-run with:
#   tmux set -g @tmux-claude-autorun on

set -uo pipefail

REGISTRY="${XDG_STATE_HOME:-$HOME/.local/state}/tmux-claude/registry.jsonl"
[ -r "$REGISTRY" ] || exit 0

autorun="$(tmux show-option -gqv @tmux-claude-autorun)"

# Give restored panes a moment to finish exec'ing their shell. Unlike
# resurrect's own pane-content `cat`, send-keys writes into the pane's input
# queue, so a late-starting shell still receives it -- but a pane still running
# its creation command would swallow the text.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  pending="$(tmux list-panes -a -F '#{pane_current_command}' 2>/dev/null \
    | grep -cE '^(cat|sh)$' || true)"
  [ "${pending:-0}" -eq 0 ] && break
  sleep 0.5
done

matched=0
while IFS=$'\t' read -r pane_key pane_cwd; do
  [ -n "$pane_key" ] || continue

  entry="$(PANE_KEY="$pane_key" PANE_CWD="$pane_cwd" python3 - "$REGISTRY" <<'PY' 2>/dev/null
import json, os, sys

pane = os.environ["PANE_KEY"]
cwd  = os.path.realpath(os.environ.get("PANE_CWD") or "")
best = None
try:
    for line in open(sys.argv[1]):
        try:
            r = json.loads(line)
        except Exception:
            continue
        if r.get("pane") != pane:
            continue
        # Fail closed: pane indices can shift between session start and restore.
        # Resuming the wrong conversation into the wrong directory is worse than
        # resuming nothing, so require the directory to agree.
        if os.path.realpath(r.get("cwd") or "") != cwd:
            continue
        if best is None or r.get("ts", 0) >= best.get("ts", 0):
            best = r
except OSError:
    pass

if best:
    cfg = best.get("config_dir") or ""
    cmd = f"CLAUDE_CONFIG_DIR={cfg} claude --resume {best['session_id']}" if cfg \
          else f"claude --resume {best['session_id']}"
    print(cmd)
PY
)"

  [ -n "$entry" ] || continue

  # Only type into panes sitting at an idle shell.
  cur="$(tmux display -p -t "$pane_key" '#{pane_current_command}' 2>/dev/null)"
  case "$cur" in
    zsh|bash|sh|fish) ;;
    *) continue ;;
  esac

  if [ "$autorun" = "on" ]; then
    tmux send-keys -t "$pane_key" "$entry" C-m 2>/dev/null || continue
  else
    tmux send-keys -t "$pane_key" "$entry" 2>/dev/null || continue
  fi
  matched=$((matched + 1))
done < <(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}	#{pane_current_path}' 2>/dev/null)

if [ "$matched" -gt 0 ]; then
  if [ "$autorun" = "on" ]; then
    tmux display-message "Resumed $matched Claude session(s)."
  else
    tmux display-message "$matched Claude session(s) queued -- press Enter in each pane."
  fi
fi

exit 0
