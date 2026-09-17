# Language home cleanup (mirror of shell/software.sh).
set -gx GRADLE_USER_HOME      "$XDG_DATA_HOME/gradle"
set -gx DOTNET_CLI_HOME       "$XDG_DATA_HOME/dotnet"
set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -gx NODE_REPL_HISTORY     "$XDG_DATA_HOME/node_repl_history"

# Tool configs.
set -gx AWS_CONFIG_FILE       "$XDG_CONFIG_HOME/aws/config"
set -gx GNUPGHOME             "$XDG_DATA_HOME/gnupg"
set -gx LESSHISTFILE          "$XDG_STATE_HOME/lesshst"
set -gx PASSWORD_STORE_DIR    "$HOME/Documents/pass"
set -gx PASSWORD_STORE_ENABLE_EXTENSIONS true
set -gx ANSIBLE_HOME          "$XDG_DATA_HOME/ansible"
set -gx ANSIBLE_REMOTE_TEMP   "$ANSIBLE_HOME/tmp"
set -gx MPLCONFIGDIR          "$XDG_CACHE_HOME/matplotlib"

# Editor.
set -gx VISUAL nvim
set -gx EDITOR $VISUAL

# Claude Code: signal the active shell + opt in to experimental features.
# Aliases that misbehave under Claude Code are gated below in aliases.fish.
set -gx CLAUDE_CODE_SHELL fish
set -gx CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 1
