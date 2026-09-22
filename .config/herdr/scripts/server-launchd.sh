#!/bin/zsh
# Launch the herdr server under launchd with a usable PATH.
#
# launchd gives a job an empty PATH, so a server started by `brew services`
# cannot find claude, codex, opencode or pi, and agent resume silently produces
# empty shells. Build the PATH explicitly here instead.
#
# Installed by bootstrap_herdr; run by ~/Library/LaunchAgents/com.andperks.herdr.plist.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x $brew_bin ]] && eval "$("$brew_bin" shellenv)" && break
done

# mise shims cover agents installed as npm packages, e.g. pi.
[[ -d $HOME/.local/share/mise/shims ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"

exec herdr server
