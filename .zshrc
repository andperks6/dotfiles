# ---- Profiling (run: ZSH_PROFILE=1 zsh) ---- #
[[ "$ZSH_PROFILE" == "1" ]] && zmodload zsh/zprof

# ---- XDG Base Directory ---- #
# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # Configurations
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"       # Non-essential (cached) data
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # State data that should persist between restarts
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State data but is not important or portable enough
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"  # Non-essential runtime files and other file objects


# if [[ -z "$VSCODE_CWD" ]]; then
#     # Commands to start tmux or attach to a session
#     # For example: tmux new-session -A -s my_session
#     if [ -z "$TMUX" ]; then
#         # tmux with p10k https://github.com/romkatv/powerlevel10k/issues/1203#issuecomment-754805535
#         exec tmux new-session -A -s workspace
#     fi
# fi



# tmux_run() {
#   parent_process=$(ps -p $PPID -o comm=)
#     # don't start in vscode
#     if [[ "$parent_process" != "code" ]]; then
#         if [ -z "$TMUX" ]; then
#             # tmux with p10k https://github.com/romkatv/powerlevel10k/issues/1203#issuecomment-754805535
#             exec tmux new-session -A -s workspace
#         fi
#     fi
# }

# tmux_run

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# ---- What gets displayed on line running command ---- #
PS1='%n@%m %~$ '


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


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- End profiling ---- #
[[ "$ZSH_PROFILE" == "1" ]] && zprof