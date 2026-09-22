# Multiplexer auto-launch — fish port of shell/tmux.sh. Gates match zsh exactly.
#
# $MUX selects one: tmux (default), herdr, or none.
set -q MUX; or set -g MUX tmux

status is-interactive; or exit
# HERDR_ENV=1 marks a herdr-managed pane: never launch a multiplexer inside one.
test -z "$TMUX"; and test "$HERDR_ENV" != 1; or exit
test "$TERM_PROGRAM" != vscode; and test -z "$VSCODE_INJECTION"; or exit
isatty 0; and isatty 1; or exit

# herdr holds every workspace in one server, so there is nothing to pick here.
if test "$MUX" = herdr
    type -q herdr; and herdr
    exit
end

test "$MUX" = tmux; or exit
type -q tmux; or exit
type -q sesh; or exit

set -l selected (sesh list -t -z -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
if test -n "$selected"
    exec sesh connect "$selected"
end
