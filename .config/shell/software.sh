# ---- Environment Specific ---- #

system_type=$(uname -s)

if [[ -z $HOMEBREW_PREFIX ]]; then
    services=()
    if [[ "${system_type}" == "Darwin" ]]; then
        brew_path="/opt/homebrew/bin/brew"
        # Add services
        # services+=("ollama")
    elif [[ "${system_type}" == "Linux" ]]; then
        brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
        # Building python with asdf: https://github.com/pyenv/pyenv/pull/2906
        export PYTHON_BUILD_USE_HOMEBREW=1
    else
        echo "Unhandled system type ${system_type}, stopping setup"
        return
    fi
    # Setup Homebrew
    [[ -x $brew_path ]] && eval "$($brew_path shellenv)"
    # Start Homebrew Services
    for service in "${services[@]}"; do
        is_running=$(brew services list | grep "$service.*started")
        if [[ -z "$is_running" ]]; then
            brew services start $service
        fi
    done
fi

# ---- Language Home Cleanup ---- #

# Gradle
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"

# C#
export DOTNET_CLI_HOME="${XDG_DATA_HOME}/dotnet"

# Node
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"

# ---- Language Setup ---- #

# Mise (replaces asdf)
if [[ -x "$(command -v mise)" ]]; then
    eval "$(mise activate zsh)"
fi

# Lua
[[ -x "$(command -v luarocks)" ]] && eval $(luarocks path --bin)

# ---- Software Home Cleanup ---- #

# AWS
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"

# Claude Code
export CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME}/claude"

# GPG
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# Less
export LESSHISTFILE="${XDG_STATE_HOME}/lesshst"

# Password Store
export PASSWORD_STORE_DIR="${HOME}/Documents/pass"

# Ansible
export ANSIBLE_HOME="${XDG_DATA_HOME}/ansible"
export ANSIBLE_REMOTE_TEMP="${ANSIBLE_HOME}/tmp"

# Matplotlib
export MPLCONFIGDIR="${XDG_CACHE_HOME}/matplotlib"

# ---- Software Setup ---- #

# Password Store
export PASSWORD_STORE_ENABLE_EXTENSIONS=true

# SSH
[[ -z $SSH_AUTH_SOCK ]] && eval "$(ssh-agent -s)"

# fzf
# [[ -x "$(command -v fzf)" ]] && eval $(fzf --zsh)

# ---- PATH ---- #

# Add shell config bin folder
export PATH="${XDG_CONFIG_HOME}/shell/bin:$PATH"

# Add user bin folder
user_bin="${HOME}/bin"
[[ -d $user_bin ]] && export PATH="${user_bin}:$PATH"

# Add System32 if it exists (WSL)
sys32_path="/mnt/c/Windows/System32"
if [[ -d $sys32_path ]]; then
    export PATH="$PATH:${sys32_path}"
    export PATH="$PATH:${sys32_path}/WindowsPowerShell/v1.0"
fi

# ---- Completions ---- #
zsh_cache_home="${XDG_CACHE_HOME}/zsh"
[[ ! -d $zsh_cache_home ]] && mkdir -p $zsh_cache_home

# Add completion directories
FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
[[ -x "$(command -v rustc)" ]] && FPATH="$(rustc --print sysroot)/share/zsh/site-functions:${FPATH}"

# man zshcompsys
zstyle ':completion:*' cache-path "${zsh_cache_home}/compcache"
# autoload -Uz compinit && compinit -d "${zsh_cache_home}/compdump"

completions_home="${XDG_DATA_HOME}/completions"
[[ ! -d $completions_home ]] && mkdir -p $completions_home

register_click_completion() {
    if [[ -x "$(command -v python)" ]]; then
        completion_file="${completions_home}/${1}-complete.zsh"
        # Generate completions only if cache doesn't exist
        if [[ ! -f $completion_file ]]; then
            click_variable=$(echo ${1} | tr '[:lower:]' '[:upper:]' | tr '-' '_')
            eval "_${click_variable}_COMPLETE=zsh_source ${1} >| ${completion_file} 2>/dev/null"
        fi
        [[ -f $completion_file ]] && source "${completion_file}"
    fi
}

# Click completions
register_click_completion "gd"
register_click_completion "git-remote"

# Update all git repos in a directory
git-pull-all() {
    local dir="${1:-.}"
    find "$dir" -name ".git" -type d 2>/dev/null | while read gitdir; do
        repo=$(dirname "$gitdir")
        echo "Updating $repo..."
        git -C "$repo" pull --ff-only 2>/dev/null || echo "  ⚠ failed or conflicts"
    done
}

# ---- Editor with Aliases ---- #

# Change default editor
export VISUAL="nvim"
export EDITOR="$VISUAL"

# Aliases common editor commands
alias n='$VISUAL .'
alias v='$VISUAL .'

vim() {
    if [[ "${#}" -eq 0 ]]; then
        nvim
    elif [[ "${#}" -eq 1 ]]; then
        if [[ -d $1 ]]; then
            cd "${1}" && nvim .
        elif [[ -f $1 ]]; then
            nvim "${1}"
        else
            echo "${1} is neither a file nor a directory"
        fi
    else
        echo "Usage: <path>?"
    fi
}

# ---- VIM Mode and Keybindings ---- #

# # Use vi mode, set explicitly
# bindkey -v
# # Fix vi mode search behavior for <esc>+/
# vi-search-fix() {
#     zle vi-cmd-mode
#     zle .vi-history-search-backward
# }
# zle -N vi-search-fix
# # For all valid escape sequences: man zshzle
# bindkey -M viins "\e/" vi-search-fix
# # Fix ability to delete characters
# bindkey "^?" backward-delete-char
# # Prefix based search
# bindkey "^[[A" history-search-backward
# bindkey "^[[B" history-search-forward
