
# install the fisher plugin manager (and plugins) if its not installed yet
if not functions --query fisher
    # don't start an infinite recursion when we start a new fish instance to
    # install fisher
    if test "$installing_fisher" != TRUE
        set -x installing_fisher TRUE
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        # restore my plugins list after its overwritten by the installer
        git restore ~/.config/fish/fish_plugins
        # and then install all my plugins
        fisher update
    end
end

#enable devbox
devbox global shellenv --init-hook | source

# Enable starship
starship init fish | source

# Enable direnv
eval (direnv hook fish)

# nix flakes needs this
set -x NIXPKGS_ALLOW_UNFREE 1
# helper nix alias
function nix
    # set -x NIX_CONFIG (secret-tool lookup name 'NIX_CONFIG')
    # set -x NIX_CONFIG (passage NIX_CONFIG)
    command nix --extra-experimental-features nix-command --extra-experimental-features flakes $argv
end

# devbox on linux needs this
set -x NIX_REMOTE daemon

#aliases
source "${XDG_CONFIG_HOME}/shell/aliases.sh"
alias reload="source ~/.config/fish/config.fish"

