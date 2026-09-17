# XDG base directories — must come first so everything else can use them.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_CACHE_HOME;  or set -gx XDG_CACHE_HOME  "$HOME/.cache"
set -q XDG_DATA_HOME;   or set -gx XDG_DATA_HOME   "$HOME/.local/share"
set -q XDG_STATE_HOME;  or set -gx XDG_STATE_HOME  "$HOME/.local/state"
set -q XDG_RUNTIME_DIR; or set -gx XDG_RUNTIME_DIR "/tmp"

# Homebrew shellenv (Apple Silicon path; Intel/Linux fall through if absent).
if test -z "$HOMEBREW_PREFIX"
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    else if test -x /home/linuxbrew/.linuxbrew/bin/brew
        /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
    end
end

# Extra PATH entries (prepended so they win over system).
test -d "$HOMEBREW_PREFIX/opt/libpq/bin" ; and fish_add_path -gP "$HOMEBREW_PREFIX/opt/libpq/bin"
fish_add_path -gP "$XDG_CONFIG_HOME/shell/bin"
test -d "$HOME/bin"        ; and fish_add_path -gP "$HOME/bin"
test -d "$HOME/.local/bin" ; and fish_add_path -gP "$HOME/.local/bin"
