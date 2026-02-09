#!/bin/bash
# .NET Development Setup
# Installs .NET SDK via mise

set -e

echo "Setting up .NET development environment..."

# Install mise tools (versions defined in ~/.config/mise/config.toml)
if [[ -x "$(command -v mise)" ]]; then
    mise install dotnet
else
    echo "Error: mise not installed. Run yadm bootstrap first."
    exit 1
fi

echo ".NET development environment setup complete!"
