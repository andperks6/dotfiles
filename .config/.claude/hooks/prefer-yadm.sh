#!/usr/bin/env bash
# Block plain `git` commands in the dotfiles tree; direct model to yadm instead.
# Only blocks when no real .git repo is found walking up from cwd to $HOME.

INPUT=$(cat /dev/stdin)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
[[ "$TOOL_NAME" != "Bash" ]] && exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only catch commands where `git` is the first word (allow yadm, gh, etc.)
[[ ! "$CMD" =~ ^[[:space:]]*git([[:space:]]|$) ]] && exit 0

# Only act when cwd is inside $HOME (dotfiles territory). Elsewhere, leave git alone.
case "$(pwd)/" in
  "$HOME"/*) ;;
  *) exit 0 ;;
esac

# If cwd is inside a real git repo (has .git walking up before $HOME), allow
dir="$(pwd)"
while [[ "$dir" != "/" && "$dir" != "$HOME" ]]; do
  if [[ -e "$dir/.git" ]]; then
    exit 0
  fi
  dir="$(dirname "$dir")"
done

cat >&2 <<'EOF'
Blocked: this tree is managed by yadm, not git. Use `yadm` instead.
  yadm status  →  instead of  git status
  yadm add X   →  instead of  git add X
  yadm commit  →  instead of  git commit
  yadm push    →  instead of  git push
  yadm diff    →  instead of  git diff
No .git repo was found walking up from cwd to $HOME, so this is dotfiles territory.
If you genuinely need plain git (e.g. inside a nested real repo), cd into it first.
EOF
exit 2
