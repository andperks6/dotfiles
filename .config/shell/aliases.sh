# General
alias reload="exec zsh"
alias update-sys="yadm pull && yadm bootstrap"
alias ll="ls -latrh"
alias workspace="cd ~/dev"

# Git
alias gs="git status -uall"
alias gl="git log"
alias gp="git push"
alias gpl="git pull"
alias ga="git add --all"
alias gc="git commit -m"
alias gb="git branch"
alias gac="git add --all && git commit --amend"
alias gm="git checkout main"
alias gu="git branch -u main"
alias gr="git rebase -i"
alias gundo="git restore ."

# Claude Code profiles — auto-switches based on working directory.
# Work repos live under ~/dev/work/, everything else is personal.
#
# An exported CLAUDE_CONFIG_DIR wins, so a directory can pin its own profile
# with an .envrc. ~/.config needs that: it maps to personal by path but is
# worked on under work, and herdr's replayed `claude --resume` would otherwise
# look for the session in the wrong profile.
claude() {
  if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
    command claude "$@"
    return
  fi
  local profile
  case "$PWD/" in
    "$HOME"/dev/work/*) profile=work ;;
    *)                  profile=personal ;;
  esac
  CLAUDE_CONFIG_DIR="$HOME/.claude/$profile" command claude "$@"
}
alias claude-work='CLAUDE_CONFIG_DIR=~/.claude/work command claude'
alias claude-personal='CLAUDE_CONFIG_DIR=~/.claude/personal command claude'

# Claude Desktop profile switching via Electron --user-data-dir.
# Default app launch (Dock/Spotlight) = work profile (~/Library/Application Support/Claude/).
# To log in to personal for the first time: quit the default Claude instance first
# so the claude:// auth deep-link routes to the personal instance.
alias claude-app-personal='open -n -a "Claude" --args --user-data-dir="$HOME/Library/Application Support/Claude-Personal"'

# Yadm
alias yb="bash ~/.config/yadm/bootstrap"
alias ys="yadm status"
alias yl="yadm log"
alias yp="yadm push"
alias ypl="yadm pull"
alias ya="yadm add -u"
alias yc="yadm commit -m"
# This repo is public. Two rules for anything added here:
#   - no directory a tool writes runtime state into (herdr drops session.json
#     and plaintext scrollback beside its config, hence the single file path)
#   - never ~/.claude/settings.json: it names client repos and describes where
#     production credentials live. Left out deliberately; do not re-add.
alias yac="yadm add ~/docs/ ~/.config/alacritty/ ~/.config/git/ ~/.config/helix/ ~/.config/kitty/ ~/.config/lang/ ~/.config/lazygit/ ~/.config/npm/ ~/.config/nvim/ ~/.config/opencode/ ~/.config/shell/ ~/.config/shellcheckrc ~/.config/tmux/ ~/.config/herdr/config.toml ~/.config/herdr/.gitignore ~/.config/herdr-sesh/ ~/.config/vim/ ~/.config/wezterm/ ~/.config/yadm/ ~/.claude/.rgignore ~/.claude/hooks/ ~/.skills ~/.skillkit/lock.json"
alias yls="yadm ls-files ~"
alias yd="yadm diff"

# bat --plain for unformatted cat
alias catp='bat -P'

# Aliases that break in Claude Code sessions (no z function, bat output issues)
if [[ -z "$CLAUDE_CODE_SHELL" ]]; then
  alias cat='bat'
  alias cd='z'
fi
