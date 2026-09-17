# tmux auto-launch via sesh — port of shell/tmux.sh. Gates match zsh exactly.
status is-interactive; or exit
type -q tmux; or exit
type -q sesh; or exit
test -z "$TMUX"                                              ; or exit
test "$TERM_PROGRAM" != vscode; and test -z "$VSCODE_INJECTION"; or exit
isatty 0; and isatty 1; or exit

set -l selected (sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
if test -n "$selected"
    exec sesh connect "$selected"
end
