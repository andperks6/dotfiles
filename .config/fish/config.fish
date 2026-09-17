# Most setup lives in conf.d/ (auto-sourced alphabetically) and functions/.
# This file handles: bootstrapping the plugin manager and the few things
# that must be set in every shell (login + non-interactive included).

# Fisher (plugin manager) bootstrap — installs itself + fish_plugins on first run.
if not functions --query fisher
    if test "$installing_fisher" != TRUE
        set -x installing_fisher TRUE
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        # The installer rewrites fish_plugins; restore ours, then install everything in it.
        git restore ~/.config/fish/fish_plugins
        fisher update
    end
end

# Nix flakes opt-ins (must be set before any `nix` invocation).
set -gx NIXPKGS_ALLOW_UNFREE 1
set -gx NIX_REMOTE daemon
