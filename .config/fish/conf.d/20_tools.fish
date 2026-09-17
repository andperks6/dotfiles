# Tool initialization (mise, atuin, direnv). Each is interactive-shell only —
# `status is-interactive` keeps scripts that source config.fish quiet/fast.
status is-interactive; or exit

# mise must come first — it adds tool shims (atuin, zoxide, etc.) to PATH.
# (Prompt is handled by Tide, installed via fisher; no init needed here.)
type -q mise; and mise activate fish | source

# cd-history (need to be init'd in interactive shells).
type -q zoxide; and zoxide init fish | source

# atuin (better history). Skipped inside Claude Code sessions (parity w/ zsh).
if type -q atuin; and test "$CLAUDECODE" != "1"
    atuin init fish | source
end

# direnv (auto-loaded .envrc per directory).
type -q direnv; and direnv hook fish | source

# luarocks (matches the zsh setup).
type -q luarocks; and luarocks path --bin | source 2>/dev/null
