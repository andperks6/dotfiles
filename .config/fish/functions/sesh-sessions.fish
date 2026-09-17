# Alt+s picker (bound in config.fish). Pick across tmux sessions, zoxide
# directories, and sesh config entries.
function sesh-sessions
    set -l session (sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    test -z "$session"; and return
    sesh connect "$session"
    commandline -f repaint
end
