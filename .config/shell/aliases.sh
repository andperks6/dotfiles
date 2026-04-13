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
claude() {
  local profile
  case "$PWD/" in
    "$HOME"/dev/work/*) profile=work ;;
    *)                  profile=personal ;;
  esac
  CLAUDE_CONFIG_DIR="$HOME/.config/claude-$profile" command claude "$@"
}
alias claude-work='CLAUDE_CONFIG_DIR=~/.config/claude-work command claude'
alias claude-personal='CLAUDE_CONFIG_DIR=~/.config/claude-personal command claude'

# Yadm
alias yb="bash ~/.config/yadm/bootstrap"
alias ys="yadm status"
alias yl="yadm log"
alias yp="yadm push"
alias ypl="yadm pull"
alias ya="yadm add -u"
alias yc="yadm commit -m"
alias yac="yadm add ~/docs/ ~/.config/alacritty/ ~/.config/git/ ~/.config/helix/ ~/.config/kitty/ ~/.config/lang/ ~/.config/lazygit/ ~/.config/npm/ ~/.config/nvim/ ~/.config/shell/ ~/.config/shellcheckrc ~/.config/tmux/ ~/.config/vim/ ~/.config/wezterm/ ~/.config/yadm/"
alias yls="yadm ls-files ~"
alias yd="yadm diff"

# bat --plain for unformatted cat
alias catp='bat -P'

# Aliases that break in Claude Code sessions (no z function, bat output issues)
if [[ -z "$CLAUDE_CODE_SHELL" ]]; then
  alias cat='bat'
  alias cd='z'
fi
