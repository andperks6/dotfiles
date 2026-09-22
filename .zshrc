# ---- Profiling (run: ZSH_PROFILE=1 zsh) ---- #
[[ "$ZSH_PROFILE" == "1" ]] && zmodload zsh/zprof

# ---- Prompt engine (p10k | starship) ---- #
# Try starship with: export PROMPT_ENGINE=starship (then restart shell).
: ${PROMPT_ENGINE:=p10k}

# ---- XDG Base Directory ---- #
# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # Configurations
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"       # Non-essential (cached) data
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # State data that should persist between restarts
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State data but is not important or portable enough
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"  # Non-essential runtime files and other file objects

# ---- Machine-specific settings ---- #
# Loaded here, not just from shell/all.sh, because the multiplexer launch below
# reads $MUX. all.sh sources it again later; it only exports, so that is safe.
[[ -f "${XDG_CONFIG_HOME}/shell/custom.sh" ]] && source "${XDG_CONFIG_HOME}/shell/custom.sh"

# ---- Auto-launch the multiplexer (must run before p10k instant prompt) ---- #
# Needs console input (fzf), so it must be above instant prompt.
[[ -z $TMUX ]] && source "${XDG_CONFIG_HOME}/shell/tmux.sh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
if [[ "$PROMPT_ENGINE" == p10k && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# ---- History configuration ---- #
zsh_state_home="${XDG_STATE_HOME}/zsh"
[[ ! -d $zsh_state_home ]] && mkdir -p $zsh_state_home

# man zshoptions
HISTSIZE=8000 # history kept in memory
SAVEHIST=5000 # history saved to file
HISTFILE="$zsh_state_home/history"
setopt append_history
setopt inc_append_history
setopt share_history

# ---- Completion search paths (must be set before Zim runs compinit) ---- #
if [[ -n $HOMEBREW_PREFIX ]]; then
    FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
elif [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
elif [[ -d /home/linuxbrew/.linuxbrew/share/zsh/site-functions ]]; then
    FPATH="/home/linuxbrew/.linuxbrew/share/zsh/site-functions:${FPATH}"
fi

# ---- Run main shell setup ---- #
shell_main() {
    source "${XDG_CONFIG_HOME}/shell/zim.zsh"
    source "${XDG_CONFIG_HOME}/shell/all.sh"

    # Init tools AFTER zim completion module loads
    if [[ "$CLAUDECODE" != "1" ]]; then
        eval "$(zoxide init zsh)"
        eval "$(atuin init zsh)"
    fi
}

shell_main


# ---- Activate prompt ---- #
# p10k is sourced directly (not via zim) so this toggle needs no zim rebuild.
# starship init uses `mise exec` because `mise activate` only adds tools to
# PATH on the first precmd, which is after this file finishes sourcing.
if [[ "$PROMPT_ENGINE" == p10k ]]; then
  p10k_theme=~/.zim/modules/powerlevel10k/powerlevel10k.zsh-theme
  [[ -r $p10k_theme ]] && source $p10k_theme
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
else
  eval "$(mise exec -- starship init zsh 2>/dev/null)"
fi

# ---- End profiling ---- #
[[ "$ZSH_PROFILE" == "1" ]] && zprof
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# bun completions
[ -s "/opt/homebrew/share/zsh/site-functions/_bun" ] && source "/opt/homebrew/share/zsh/site-functions/_bun"
