#!/bin/zsh
# Tab triage routine — ONE weekly headless Claude run that snapshots Firefox
# tab state (the PHONE's open tabs arrive via Firefox Sync -> synced-tabs.db
# in the desktop profile; the desktop session is secondary context) and
# triages every mobile tab into FORGET / REMAIN / REMEMBER:
#   FORGET   -> listed in the report so closing them on the phone is safe
#   REMAIN   -> kept, with a one-line "why" + suggested grouping
#   REMEMBER -> captured into the default Obsidian vault (~/Documents/default)
# Nothing in the browser is ever modified — closing tabs stays a manual,
# now-safe sweep on the phone once the run has captured what matters.
#
# Invoked by launchd: com.andperks.tab-triage (Sun 17:00 weekly).
# Canonical copy in dotfiles (~/.config/claude/routines); symlinked into LaunchAgents.
#
# REQUIRES Full Disk Access on /bin/zsh — the vault is under ~/Documents and
# the Firefox profile under ~/Library/Application Support; both TCC-protected.
#
# Manual test:  /bin/zsh ~/.config/claude/routines/tab-triage.sh
set -u

LOG="$HOME/Library/Logs/claude-tab-triage.log"

# launchd/systemd hand us a bare env — set PATH so claude/sqlite3/awk resolve
# (covers macOS Homebrew + typical Linux locations).
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# Resolve the real claude binary, bypassing the interactive `claude` shell
# function (`whence -p` ignores functions/aliases; falls back to command -v).
CLAUDE_BIN="$(whence -p claude 2>/dev/null || command -v claude 2>/dev/null)"
if [[ -z "$CLAUDE_BIN" ]]; then
  echo "$(date '+%F %T') ERROR: claude binary not found on PATH" >>"$LOG"
  exit 127
fi

# Same creds/settings as daily-log; output goes only to the personal vault.
export CLAUDE_CONFIG_DIR="$HOME/.claude/work"

PROMPT_FILE="$HOME/Documents/default/templates/Tab Triage Prompt.md"

# Pull the prompt out of the single fenced code block in the note.
PROMPT="$(awk '/^```/{f=!f; next} f' "$PROMPT_FILE" 2>/dev/null)"
if [[ -z "$PROMPT" ]]; then
  echo "$(date '+%F %T') ERROR: empty/unreadable prompt at $PROMPT_FILE — grant Full Disk Access to /bin/zsh (TCC)?" >>"$LOG"
  exit 1
fi

# --- Locate the default Firefox profile --------------------------------------
FF_ROOT="$HOME/Library/Application Support/Firefox"
[[ -d "$FF_ROOT" ]] || FF_ROOT="$HOME/.mozilla/firefox"   # Linux fallback
PROFILES_INI="$FF_ROOT/profiles.ini"

PROFILE_REL="$(awk -F= '/^\[Install/{f=1;next} /^\[/{f=0} f && $1=="Default"{print $2; exit}' "$PROFILES_INI" 2>/dev/null)"
PROFILE_DIR=""
[[ -n "$PROFILE_REL" ]] && PROFILE_DIR="$FF_ROOT/$PROFILE_REL"

if [[ -z "$PROFILE_DIR" || ! -f "$PROFILE_DIR/synced-tabs.db" ]]; then
  # Fallback: the profile with the most recently touched synced-tabs.db.
  DB="$(ls -t "$FF_ROOT"/*/synced-tabs.db 2>/dev/null | head -1)"
  [[ -n "$DB" ]] && PROFILE_DIR="${DB:h}"
fi

if [[ -z "$PROFILE_DIR" || ! -f "$PROFILE_DIR/synced-tabs.db" ]]; then
  echo "$(date '+%F %T') ERROR: no Firefox profile with synced-tabs.db under $FF_ROOT — is Firefox Sync set up? (Or FDA missing on /bin/zsh.)" >>"$LOG"
  exit 1
fi

# --- Snapshot the data (Firefox holds locks; never read live files) ----------
WORKDIR="$(mktemp -d /tmp/tab-triage.XXXXXX)"
trap 'rm -rf "$WORKDIR"' EXIT

cp "$PROFILE_DIR"/synced-tabs.db*(N) "$WORKDIR/"   # db + -wal/-shm if present
REC="$PROFILE_DIR/sessionstore-backups/recovery.jsonlz4"
[[ -f "$REC" ]] && cp "$REC" "$WORKDIR/"

PROMPT+="

RUNTIME CONTEXT (appended by tab-triage.sh — paths for THIS run):
- Snapshot dir: $WORKDIR
  - synced-tabs.db (+ -wal/-shm if present): SQLite snapshot of Firefox Sync remote-client tabs — the phone's open tabs live here.
  - recovery.jsonlz4 (only if present): desktop session snapshot, mozLz4-compressed JSON — secondary context only.
- Source Firefox profile (reference only, do NOT read or modify it): $PROFILE_DIR
- Today's date: $(date '+%F')"

cd "$HOME" || exit 1

{
  echo "===== $(date '+%F %T') tab-triage start ====="
  "$CLAUDE_BIN" -p "$PROMPT" --permission-mode bypassPermissions
  rc=$?
  echo "===== $(date '+%F %T') tab-triage finished (exit=$rc) ====="
} >>"$LOG" 2>&1
