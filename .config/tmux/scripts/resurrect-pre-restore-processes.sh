#!/usr/bin/env bash
# tmux-resurrect @resurrect-hook-pre-restore-pane-processes
#
# Fixes the pane-content race that lost most scrollback in the 2026-07-27 crash.
#
# resurrect restores scrollback by giving each pane the command
#   cat '<restore-dir>/pane_contents/pane-<sess>:<win>.<idx>'; exec $SHELL
# but `new-window -d` / `split-window` return immediately, so those `cat`s run
# asynchronously. At the end of main() resurrect calls
# cleanup_restored_pane_contents -> `rm <restore-dir>/*` with no barrier, so on
# a large restore the files are deleted before later panes ever read them and
# those panes come back blank. Upstream even concedes the ordering is a guess:
#   "A cleanup that happens after 'restore_all_panes' seems to fix fish shell
#    users' restore problems."
#
# This hook runs after every pane is created but before the rm, and blocks until
# no process still references a pane-content file. Detection is exact rather
# than heuristic: the file path is in the pane command's argv, so a match means
# that pane has not finished reading yet. The "[p]ane-" bracket keeps pgrep from
# matching its own command line.
#
# Wired via the documented hook API rather than patching restore.sh, so a TPM
# plugin update cannot silently revert it.

set -uo pipefail

TIMEOUT_SECONDS="${RESURRECT_CONTENT_BARRIER_TIMEOUT:-30}"
PATTERN='pane_contents/[p]ane-'

deadline=$((SECONDS + TIMEOUT_SECONDS))
while pgrep -f "$PATTERN" >/dev/null 2>&1; do
  if [ "$SECONDS" -ge "$deadline" ]; then
    # Don't hang a restore forever; losing some scrollback beats a stuck server.
    remaining="$(pgrep -f "$PATTERN" 2>/dev/null | wc -l | tr -d ' ')"
    tmux display-message \
      "resurrect: ${remaining} pane(s) still loading scrollback after ${TIMEOUT_SECONDS}s; continuing" \
      2>/dev/null || true
    break
  fi
  sleep 0.2
done

exit 0
