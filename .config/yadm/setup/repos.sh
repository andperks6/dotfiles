#!/bin/bash
# Personal Repositories Setup
# Clones and sets up personal repos using gh cli

set -e

PERSONAL_DIR="${HOME}/dev"

echo "Setting up personal repositories..."

if [[ ! -x "$(command -v gh)" ]]; then
    echo "Error: gh cli not installed."
    exit 1
fi

# Check gh auth status
if ! gh auth status &>/dev/null; then
    echo "Error: Not authenticated with gh. Run: gh auth login"
    exit 1
fi

mkdir -p "$PERSONAL_DIR"

clone_repo() {
    local repo="$1"
    local dest="${PERSONAL_DIR}/${repo}"

    if [[ -d "$dest" ]]; then
        echo "Repository ${repo} already exists at ${dest}, skipping..."
    else
        echo "Cloning ${repo}..."
        gh repo clone "andperks/${repo}" "$dest"
    fi
}

install_repo() {
    local repo="$1"
    local dest="${PERSONAL_DIR}/${repo}"

    if [[ -d "$dest" ]] && [[ -f "${dest}/justfile" ]]; then
        echo "Installing ${repo}..."
        (cd "$dest" && just install)
    fi
}

# Clone repos
clone_repo "otter-eats-sanity"
clone_repo "mirror-mirror-UI"

# Install repos with justfiles
install_repo "otter-eats-sanity"


echo "Personal repositories setup complete!"
