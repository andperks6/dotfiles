# ---- Common setup ---- #
source "${XDG_CONFIG_HOME}/shell/aliases.sh"
source "${XDG_CONFIG_HOME}/shell/software.sh"
source "${XDG_CONFIG_HOME}/shell/sesh.zsh"

# ---- Computer specific setup ---- #
# Already sourced from ~/.zshrc before the multiplexer launch, which needs $MUX.
# Repeated here for shells that do not go through ~/.zshrc. Exports only.
custom_shell="${XDG_CONFIG_HOME}/shell/custom.sh"
[[ -f $custom_shell ]] && source "${custom_shell}"

# ---- Sesh/tmux auto-launch ---- #
# Moved to ~/.zshrc (before p10k instant prompt) for fzf compatibility
