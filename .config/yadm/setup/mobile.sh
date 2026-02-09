#!/bin/bash
# Mobile Development Setup
# Installs Flutter via Homebrew

set -e

echo "Setting up mobile development environment..."

# Install brew casks
if [[ -x "$(command -v brew)" ]]; then
    brew install --cask flutter
else
    echo "Error: Homebrew not installed."
    exit 1
fi

# Flutter doctor check
if [[ -x "$(command -v flutter)" ]]; then
    echo "Running flutter doctor..."
    flutter doctor
    echo ""
    echo "You may need to run: flutter doctor --android-licenses"
fi

echo "Mobile development environment setup complete!"
