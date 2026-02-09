#!/bin/bash
# JVM Development Setup
# Installs Java, Kotlin, Gradle via mise and IntelliJ via Homebrew

set -e

echo "Setting up JVM development environment..."

# Install mise tools (versions defined in ~/.config/mise/config.toml)
if [[ -x "$(command -v mise)" ]]; then
    mise install java github:JetBrains/kotlin gradle
else
    echo "Error: mise not installed. Run yadm bootstrap first."
    exit 1
fi

# Install brew casks (skip if already installed)
if [[ -x "$(command -v brew)" ]]; then
    if ! brew list --cask intellij-idea-ce &>/dev/null; then
        brew install --cask intellij-idea-ce
    else
        echo "IntelliJ IDEA CE already installed, skipping..."
    fi
fi

# macOS Java integration
# mise prints the required commands during install - run them if the symlink doesn't exist
if [[ "$(uname -s)" == "Darwin" ]]; then
    java_version=$(mise current java 2>/dev/null)
    if [[ -n "$java_version" ]]; then
        java_install_path="${XDG_DATA_HOME:-$HOME/.local/share}/mise/installs/java/${java_version}"
        java_system_path="/Library/Java/JavaVirtualMachines/${java_version}.jdk"

        if [[ -d "$java_install_path/Contents" ]] && [[ ! -e "$java_system_path" ]]; then
            echo "Setting up macOS Java integration for ${java_version}..."
            sudo mkdir -p "$java_system_path"
            sudo ln -s "$java_install_path/Contents" "$java_system_path/Contents"
        fi
    fi
fi

echo "JVM development environment setup complete!"
