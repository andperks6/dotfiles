# ---- Common setup ---- #
source "${XDG_CONFIG_HOME}/shell/aliases.sh"
source "${XDG_CONFIG_HOME}/shell/software.sh"
source "${XDG_CONFIG_HOME}/shell/sesh.zsh"

# ---- Computer specific setup ---- #
custom_shell="${XDG_CONFIG_HOME}/shell/custom.sh"
[[ -f $custom_shell ]] && source "${custom_shell}"

# ---- Sesh/tmux auto-launch ---- #
# Moved to ~/.zshrc (before p10k instant prompt) for fzf compatibility
