#!/usr/bin/env bash
# Install / refresh the Claude routines' schedulers. Idempotent — safe to
# re-run. Called by yadm bootstrap (bootstrap_daily_log) and runnable by hand:
#   ~/.config/claude/routines/install.sh
#
# Routines (one <name>.sh + com.andperks.<name>.plist per routine):
#   daily-log   — 18:00 daily
#   tab-triage  — Sun 17:00 weekly
#
#   macOS -> launchd LaunchAgents (com.andperks.<name>)
#   Linux -> systemd --user timers (fallback: prints cron lines)
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# name|systemd OnCalendar|cron|human-readable schedule
ROUTINES=(
  "daily-log|*-*-* 18:00:00|0 18 * * *|18:00 daily"
  "tab-triage|Sun *-*-* 17:00:00|0 17 * * 0|Sun 17:00 weekly"
)

# Warn (don't fail) if a prompt hasn't synced to this machine yet — prompts
# live in the Obsidian vault, not in dotfiles.
for p in "$HOME/Documents/default/templates/Daily Log Prompt.md" \
         "$HOME/Documents/default/templates/Tab Triage Prompt.md"; do
  [[ -f "$p" ]] || echo "⚠ prompt not found at '$p' — sync your Obsidian vault; that routine errors until it exists."
done

case "$(uname -s)" in
  Darwin)
    mkdir -p "$HOME/Library/LaunchAgents"
    for entry in "${ROUTINES[@]}"; do
      IFS='|' read -r name _cal _cron human <<<"$entry"
      label="com.andperks.$name"
      chmod +x "$DIR/$name.sh" 2>/dev/null || true
      src="$DIR/$label.plist"
      dest="$HOME/Library/LaunchAgents/$label.plist"
      ln -sf "$src" "$dest"
      launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
      if launchctl bootstrap "gui/$(id -u)" "$dest" 2>/dev/null; then
        echo "✓ $name: launchd agent '$label' loaded ($human)."
      else
        echo "⚠ $name: launchctl bootstrap failed — load manually: launchctl bootstrap gui/\$(id -u) '$dest'"
      fi
    done
    echo "  ⚠ One-time manual step (macOS TCC): grant Full Disk Access to /bin/zsh"
    echo "    (System Settings › Privacy & Security › Full Disk Access › + › /bin/zsh)."
    echo "    Vaults live under ~/Documents and the Firefox profile under"
    echo "    ~/Library/Application Support (both protected); without FDA the runs"
    echo "    log 'empty/unreadable prompt' or fail to find synced-tabs.db."
    ;;
  Linux)
    if ! command -v systemctl >/dev/null 2>&1; then
      echo "⚠ systemd not found. Add cron entries manually:"
      for entry in "${ROUTINES[@]}"; do
        IFS='|' read -r name _cal cron _human <<<"$entry"
        echo "    $cron  $DIR/$name.sh"
      done
      exit 0
    fi
    unit_dir="$HOME/.config/systemd/user"
    mkdir -p "$unit_dir"
    for entry in "${ROUTINES[@]}"; do
      IFS='|' read -r name cal _cron human <<<"$entry"
      chmod +x "$DIR/$name.sh" 2>/dev/null || true
      cat > "$unit_dir/$name.service" <<EOF
[Unit]
Description=Claude routine: $name

[Service]
Type=oneshot
ExecStart=$DIR/$name.sh
EOF
      cat > "$unit_dir/$name.timer" <<EOF
[Unit]
Description=Run $name ($human)

[Timer]
OnCalendar=$cal
Persistent=true

[Install]
WantedBy=timers.target
EOF
    done
    systemctl --user daemon-reload
    for entry in "${ROUTINES[@]}"; do
      IFS='|' read -r name _cal _cron human <<<"$entry"
      systemctl --user enable --now "$name.timer"
      echo "✓ $name: systemd --user timer enabled ($human)."
    done
    echo "  For runs while logged out: sudo loginctl enable-linger $USER"
    ;;
  *)
    echo "⚠ unsupported OS '$(uname -s)' — no scheduler installed."
    ;;
esac
