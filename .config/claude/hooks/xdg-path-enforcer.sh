#!/bin/bash
# Blocks tool calls that reference ~/.claude when they should use ~/.config/claude/
# Enforces XDG compliance for Claude Code config paths

INPUT=$(cat /dev/stdin)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

case "$TOOL_NAME" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
    ;;
  Read|Edit|Write|Glob|Grep)
    CMD=$(echo "$INPUT" | jq -r '
      (.tool_input.file_path // "") + " " +
      (.tool_input.path // "") + " " +
      (.tool_input.pattern // "")
    ')
    ;;
  *)
    exit 0
    ;;
esac

# Detect ~/.claude or $HOME/.claude that is NOT under .config/
# Strip any .config/claude references first, then check if bare ~/.claude remains
STRIPPED=$(echo "$CMD" | sed 's|~/.config/claude||g; s|\.config/claude||g; s|/Users/[^/]*/\.config/claude||g')

if echo "$STRIPPED" | grep -qE '~/\.claude|/Users/[^/]*/\.claude'; then
  echo "Blocked: Use ~/.config/claude/ instead of ~/.claude/ (XDG compliance). Key paths: ~/.config/claude/history.jsonl (history), ~/.config/claude/settings.json (settings), ~/.config/claude/projects/ (conversations)" >&2
  exit 2
fi

exit 0
