# macOS dotfiles

Zsh configuration with Oh My Zsh, Powerlevel10k, Vim mode, suggestions and syntax highlighting. Supports Apple Silicon and Intel Homebrew locations.

## Install on another Mac

Have Git available (for example via Xcode Command Line Tools: `xcode-select --install`), then:

```sh
git clone git@github.com:ValiaIsNotProgrammer/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash bootstrap.sh --dry-run
bash bootstrap.sh
```

By default, bootstrap only clones missing shell plugins and links the configuration. Git is a prerequisite and is never installed. Homebrew is not required unless you opt in with `--brew`:

```sh
bash bootstrap.sh --brew --dry-run  # preview including optional packages
bash bootstrap.sh --brew            # install missing neovim/ripgrep via Homebrew
bash install.sh --dry-run            # preview local configuration changes only
bash install.sh                      # apply local configuration only
```

`--dry-run` (also accepted as `--dry-install`) reports existing dependencies, missing plugins/packages, conflicts, backups and links without writing files, cloning repositories or installing packages. It does not check network access or fetch available versions. Homebrew itself must be installed separately for `--brew`. Existing formulae and plugin repositories are not upgraded. The dry run can therefore be used before installing Homebrew, too.

Existing configuration is backed up, not merged automatically. Before restarting the shell, copy any machine-specific functions you still need from the backup into `functions/*.zsh`, and environment settings into `~/.zshrc.local`. Avoid sourcing the entire old `.zshrc`, which could initialize plugins and PATH twice.

Each replaced config is backed up under `~/.dotfiles-backups/<timestamp>-<pid>/`. Re-running installation leaves correct symlinks alone. To undo, remove the symlinks and copy the corresponding original files back from that backup. Keep this repository at its installed location, or rerun installation after moving it.

## Local settings

`~/.zshrc.local` (interactive shells) and `~/.zprofile.local` (login shells) are optional, private files outside this repository. Put credentials and machine-specific environment variables there. Put local shell functions in `functions/*.zsh` inside this repository: for example, `functions/chatgpt.zsh`, `functions/codex.zsh` and `functions/proxy.zsh`. The entire `functions/` directory is ignored by Git; installation creates it and copies missing defaults from `templates/functions/`. Existing local function files are never overwritten. Files are sourced alphabetically after `.zshrc.local`. An absent or empty directory is valid. `move_to_trash` and its `rm` alias are seeded into `functions/move_to_trash.zsh`; the starter template is tracked, while the active copy is local. Changes to templates do not update an existing local copy. Transfer them separately and securely if needed. Do not commit SSH/GPG keys, password stores, history or tokens.

Node/NVM, Bun, Rust, TeX, Yandex Cloud, Docker and OpenVPN are optional and installed separately. Existing installations are picked up conditionally. `PYTHONBREAKPOINT=pudb.set_trace` requires `pudb` in the Python environment where it is used. Private proxy commands may also require `pass` and local helper scripts; these are not distributed here.

The Powerlevel10k configuration is included. Use a Nerd Font in the terminal for its symbols, or run `p10k configure` to adjust the prompt. Terminal application settings and fonts are not included.

## Deleting files

The interactive `rm` alias moves files to `~/.trash`, preserving the previous workflow. This is not Finder Trash and is not an implementation of all `rm` flags: flags are ignored, and `--` permits names starting with a dash. Missing files produce an error. Use `command rm` for the real command when its exact semantics are needed.

## Neovim

Neovim's configuration remains in its separate repository:

```sh
git clone git@github.com:ValiaIsNotProgrammer/nvim_config.git ~/.config/nvim
```

Only do this when the destination does not already contain a configuration. Neovim plugins and language servers have their own installation requirements.
