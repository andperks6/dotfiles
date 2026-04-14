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
curl -fsSL https://raw.githubusercontent.com/andperks6/dotfiles/main/setup.sh -o setup.sh && chmod +x setup.sh
```

## Execute Script Commands in Order

| Command            | Description                                                                 |
| ------------------ | --------------------------------------------------------------------------- |
| `./setup.sh deps`  | Installs system dependencies (Linux only — no-op on macOS)                  |
| `./setup.sh brew`  | Installs Homebrew                                                           |
| `./setup.sh zsh`   | Installs zim (zsh framework)                                                |
| `./setup.sh auth`  | Installs `gh` and runs `gh auth login` (generates SSH key + uploads to GH)  |
| `./setup.sh yadm`  | Installs yadm, clones the dotfiles repo, and runs bootstrap                 |
| `./setup.sh clean` | Deletes the setup script                                                    |

The `auth` step must run before `yadm` — yadm clones via SSH and needs GitHub access first.

`./setup.sh shell` also exists but is deprecated (installed fish as default; now on zsh).

## What yadm bootstrap does
After cloning, `yadm bootstrap` runs automatically:
- Installs everything in `~/.config/yadm/Brewfile` (CLI tools, casks, fonts)
- Installs mise-managed languages and tools (bun, go, k9s, kubectl, node, python, ruby, rust, terraform, uv, zig, etc.)
- Installs Python/Rust/Node libraries and tmux plugins

## Optional setup scripts
After bootstrap, see `~/.config/yadm/setup/`:
- `jvm.sh` — Java, Kotlin, Gradle, IntelliJ
- `dotnet.sh` — .NET SDK
- `mobile.sh` — Flutter
- `repos.sh` — clone personal repositories

## Why who installs what
- **brew** for applications (casks, [precompiled binaries](https://www.reddit.com/r/Nix/comments/zdcteb/comment/iz2poto/)) and for tools that need global state ([npm/python globals don't work well in sandboxed envs](https://github.com/jetify-com/devbox/issues/17))
- **mise** for language versions and per-project tools (replaced devbox)


