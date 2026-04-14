#!/bin/bash

if [[ "${#}" -ne 1 ]]; then
    echo "Usage: <command>"
    exit 1
fi

system_type=$(uname -s)
echo "System type: ${system_type}"

install_deps() {
    echo "Installing dependencies"
    if [[ "${system_type}" == "Darwin" ]]; then
        echo "  None"
    elif [[ "${system_type}" == "Linux" ]]; then
        echo "  Starting"
        sudo apt --yes install \
          bubblewrap \
          build-essential \
          gcc \
          git \
          latexmk \
          libbz2-dev \
          libffi-dev \
          liblzma-dev \
          libncursesw5-dev \
          libreadline-dev \
          libsqlite3-dev \
          libssl-dev \
          libxml2-dev \
          libxmlsec1-dev \
          llvm \
          make \
          texlive \
          texlive-xetex \
          tk-dev \
          wget \
          wl-clipboard \
          xz-utils \
          zlib1g-dev
    else
        echo "  Error: unhandled system type"
        exit 1
    fi
}

install_shells() {
    if [[ "${system_type}" == "Linux" ]]; then
        sudo apt --yes install zsh
        sudo apt-add-repository ppa:fish-shell/release-3
        sudo apt-get install fish
    elif [[ "${system_type}" == "Darwin" ]]; then
        brew install fish
        # zsh is pre-installed on macOS
    fi
    echo ""
    echo "To set your default shell:"
    echo "  chsh -s \$(which zsh)"
    echo "  chsh -s \$(which fish)"
}

evaluate_homebrew() {
    echo "Evaluating homebrew"
    if [[ -z $(command -v brew) ]]; then
        if [[ "${system_type}" == "Darwin" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ "${system_type}" == "Linux" ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        else
            echo "  Error: unhandled system type"
            exit 1
        fi
        echo "  Done"
    else
        echo "  Already evaluated"
    fi
}

install_homebrew() {
    echo "Installing homebrew"
    if [[ -z $(command -v brew) ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "  Done"
    else
        echo "  Already installed"
    fi
    evaluate_homebrew
}

brew_install() {
    evaluate_homebrew
    echo "Installing ${1} with homebrew"
    brew list ${1}
    # $? is a special value that stores the exit status of the last executed command
    if [[ $? == 0 ]]; then
        echo "  Already installed"
    else
        brew install ${1}
        echo "  Done"
    fi
}

setup_auth() {
    # Install gh early so it can generate an SSH key and upload it to GitHub.
    # Required before `yadm clone` (which uses git@github.com:).
    brew_install "gh"

    if gh auth status >/dev/null 2>&1; then
        echo "  Already authenticated with gh"
    else
        echo "Running: gh auth login"
        echo "  Select: GitHub.com > SSH > Generate a new SSH key > authenticate via browser"
        gh auth login
    fi
}

install_yadm() {
    # https://formulae.brew.sh/formula/yadm
    brew_install "yadm"

    # https://yadm.io/docs/bootstrap
    echo "Cloning dotfiles repo"
    yadm_directory="$HOME/.config/yadm"
    if [[ -d $yadm_directory ]]; then
        echo "  Already cloned"
    else
        yadm clone --bootstrap git@github.com:andperks6/dotfiles.git
        echo "  Done"
    fi
}

cleanup_script() {
    echo "Deleting setup.sh"
    rm -rf "setup.sh"
    echo "  Done"
}

case ${1} in
  "deps")
    install_deps
    ;;
  "brew")
    install_homebrew
    ;;
  "shell")
    install_shells
    ;;
  "auth")
    setup_auth
    ;;
  "yadm")
    install_yadm
    ;;
  "clean")
    cleanup_script
    ;;
  *)
    echo "Unknown command: ${1}"
    echo "Commands: deps, brew, shell, auth, yadm, clean"
    exit 1
    ;;
esac
