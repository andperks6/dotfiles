# PWD-based Claude Code profile auto-switch. Work repos live under ~/dev/work/;
# anything else uses the personal profile.
function claude
    set -l profile personal
    string match -q "$HOME/dev/work/*" -- "$PWD/" ; and set profile work
    CLAUDE_CONFIG_DIR=$HOME/.claude/$profile command claude $argv
end
