# Aliases — fish port of shell/aliases.sh. Function-form aliases that need
# arguments live in functions/ (claude, vim, git-pull-all).

# General
alias reload    'exec fish'
alias update-sys 'yadm pull && yadm bootstrap'
alias ll        'ls -latrh'
alias workspace 'cd ~/dev'

# Editor shortcuts
alias n 'nvim .'
alias v 'nvim .'

# Git
alias gs    'git status -uall'
alias gl    'git log'
alias gp    'git push'
alias gpl   'git pull'
alias ga    'git add --all'
alias gc    'git commit -m'
alias gb    'git branch'
alias gac   'git add --all && git commit --amend'
alias gm    'git checkout main'
alias gu    'git branch -u main'
alias gr    'git rebase -i'
alias gundo 'git restore .'

# Claude Code profile shortcuts (the `claude` function does PWD-based auto-switching)
alias claude-work     'CLAUDE_CONFIG_DIR=~/.claude/work command claude'
alias claude-personal 'CLAUDE_CONFIG_DIR=~/.claude/personal command claude'
alias claude-app-personal 'open -n -a Claude --args --user-data-dir="$HOME/Library/Application Support/Claude-Personal"'

# Yadm
alias yb  'bash ~/.config/yadm/bootstrap'
alias ys  'yadm status'
alias yl  'yadm log'
alias yp  'yadm push'
alias ypl 'yadm pull'
alias ya  'yadm add -u'
alias yc  'yadm commit -m'
alias yls 'yadm ls-files ~'
alias yd  'yadm diff'

# bat without paging
alias catp 'bat -P'

# Replace cat/cd, but NOT inside Claude Code (they break its shell tooling).
if test -z "$CLAUDECODE"
    type -q bat;     and alias cat 'bat'
    type -q zoxide;  and alias cd  'z'
end
