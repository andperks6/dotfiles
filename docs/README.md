# Introduction

Using [yadm](https://yadm.io/) to store all my dotfiles

# Commands

| Command          | Description                      |
| ---------------- | -------------------------------- |
| `yadm bootstrap` | Run bootstrap script             |
| `yadm status`    | Status of yadm git repository    |
| `yadm add -u`    | Stage all modified files at once |
| `yadm push`      | Push commited changes            |

# Setup

## Download Setup Script

```bash
curl -fsSL https://raw.githubusercontent.com/andperks6/dotfiles/main/docs/setup.sh -o setup.sh && chmod +x setup.sh
```

## Execute Script Commands in Order

| Command             | Description                                      |
| ------------------- | ------------------------------------------------ |
| `./setup.sh deps`   | Installs dependencies (linux only)               |
| `./setup.sh brew`   | Installs homebrew                                |
| `./setup.sh shell`  | Adds fish and zsh, changes default to fish       |
| `./setup.sh zsh`    | adds zim to zsh                                  |
| `./setup.sh devbox` | sets up devbox and global packages               |
| `./setup.sh git`    | configures git                                   |
| `./setup.sh yadm`   | Installs [yadm](https://yadm.io/) and bootstraps |
| `./setup.sh clean`  | Deletes the setup script                         |

## Why who installs what
brew for applications, particularly for casks for [precompiled binaries](https://www.reddit.com/r/Nix/comments/zdcteb/comment/iz2poto/)
brew for languages with version management and package managers that require global state [npm and python global packages don't work](https://github.com/jetify-com/devbox/issues/17)
devbox for tools needed on any project like git 


