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

# bat
# bat --plain for unformatted cat
alias catp='bat -P'
# replace cat with bat
alias cat='bat'
# zoxide
# zoxide for smart cd
alias cd='z'
