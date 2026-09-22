#!/bin/zsh
# Launch the herdr server under launchd with a usable PATH.
#
# launchd gives a job an empty PATH, so a server started by `brew services`
# cannot find claude, codex, opencode or pi, and agent resume silently produces
# empty shells. Build the PATH explicitly here instead.
#
# Installed by bootstrap_herdr; run by ~/Library/LaunchAgents/com.andperks.herdr.plist.

# Drop any agent session markers inherited from the caller. Panes inherit the
# server's environment, so a server started from inside a Claude Code pane
# gives every future pane that session's CLAUDE_CODE_CHILD_SESSION, which turns
# transcript saving off, plus its session id and messaging credentials.
# launchd starts this with a clean environment; this guard covers running the
# script by hand. CLAUDE_CODE_SHELL and the feature flags below are set by the
# user's own shell config and are deliberately kept.
for var in ${(k)parameters[(I)CLAUDE_CODE_*]}; do
    case $var in
        CLAUDE_CODE_SHELL|CLAUDE_CODE_EXPERIMENTAL_*) ;;
        *) unset "$var" ;;
    esac
done
unset ANTHROPIC_API_KEY

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x $brew_bin ]] && eval "$("$brew_bin" shellenv)" && break
done

# mise shims cover agents installed as npm packages, e.g. pi.
[[ -d $HOME/.local/share/mise/shims ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"

exec herdr server
