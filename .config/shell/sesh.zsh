# Sesh - Smart session manager for tmux
# https://github.com/joshmedeski/sesh

# Sesh session selection function
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    # Include tmux sessions (-t), zoxide directories (-z), and config (-c)
    session=$(sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

# Register as a zle widget
zle -N sesh-sessions

# Keybindings - Alt+s to open sesh session picker
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions
