#!/bin/zsh
# Daily log routine — ONE headless Claude run that reads both Claude profile
# histories (~/.claude/{work,personal}/history.jsonl) + git/gh activity, and
# writes/updates daily notes into BOTH Obsidian vaults, routing each session by
# repo/content:
#   WORK     -> ~/Documents/blackthorn
#   PERSONAL -> ~/Documents/default
#
# Invoked by launchd: com.andperks.daily-log.
# Canonical copy in dotfiles (~/.config/claude/routines); symlinked into LaunchAgents.
#
# REQUIRES Full Disk Access on /bin/zsh — the vaults are under ~/Documents, which
# macOS TCC protects; without FDA, launchd cannot READ files there (EPERM).
#
# Manual test:  /bin/zsh ~/.config/claude/routines/daily-log.sh
set -u

LOG="$HOME/Library/Logs/claude-daily-log.log"

# launchd/systemd hand us a bare env — set PATH so claude/gh/git/awk resolve
# (covers macOS Homebrew + typical Linux locations).
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# Resolve the real claude binary, bypassing the interactive `claude` shell
# function (`whence -p` ignores functions/aliases; falls back to command -v).
CLAUDE_BIN="$(whence -p claude 2>/dev/null || command -v claude 2>/dev/null)"
if [[ -z "$CLAUDE_BIN" ]]; then
  echo "$(date '+%F %T') ERROR: claude binary not found on PATH" >>"$LOG"
  exit 127
fi

# Run under the work login (active); both history files are read by absolute
# path in the prompt, so this only picks which creds/settings the run uses.
export CLAUDE_CONFIG_DIR="$HOME/.claude/work"

PROMPT_FILE="$HOME/Documents/default/templates/Daily Log Prompt.md"

# Pull the prompt out of the single fenced code block in the note.
PROMPT="$(awk '/^```/{f=!f; next} f' "$PROMPT_FILE" 2>/dev/null)"
if [[ -z "$PROMPT" ]]; then
  echo "$(date '+%F %T') ERROR: empty/unreadable prompt at $PROMPT_FILE — grant Full Disk Access to /bin/zsh (TCC)?" >>"$LOG"
  exit 1
fi

cd "$HOME" || exit 1

{
  echo "===== $(date '+%F %T') daily-log start ====="
  "$CLAUDE_BIN" -p "$PROMPT" --permission-mode bypassPermissions
  rc=$?
  echo "===== $(date '+%F %T') daily-log finished (exit=$rc) ====="
} >>"$LOG" 2>&1
