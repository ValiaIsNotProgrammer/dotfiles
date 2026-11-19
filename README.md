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
bash bootstrap.sh --brew --nvim --dry-run  # preview packages, Ghostty config and Neovim
bash bootstrap.sh --brew --nvim            # install missing neovim/ripgrep/fd and clone Neovim config
bash install.sh --dry-run            # preview local configuration changes only
bash install.sh                      # apply local configuration only
bash doctor.sh                       # read-only checks; nonzero exit on errors
```

`--dry-run` (also accepted as `--dry-install`) reports existing dependencies, missing plugins/packages, conflicts, backups and links without writing files, cloning repositories or installing packages. It does not check network access or fetch available versions. Homebrew itself must be installed separately for `--brew`. Existing formulae and plugin repositories are not upgraded. Homebrew is discovered in PATH, then `~/.homebrew`, `/opt/homebrew`, or `/usr/local`; the same discovery is used by `.zprofile` and `doctor.sh`. `--nvim` clones the separate Neovim config only if its destination is absent; existing configurations are kept, never overwritten or pulled automatically. Missing `rg` is reported even when `--brew` is omitted. The dry run can therefore be used before installing Homebrew, too.

Existing configuration is backed up, not merged automatically. Before restarting the shell, copy any machine-specific functions you still need from the backup into `functions/*.zsh`, and environment settings into `~/.zshrc.local`. Avoid sourcing the entire old `.zshrc`, which could initialize plugins and PATH twice.

Each replaced config is backed up under `~/.dotfiles-backups/<timestamp>-<pid>/`. Re-running installation leaves correct symlinks alone. To undo, remove the symlinks and copy the corresponding original files back from that backup. Keep this repository at its installed location, or rerun installation after moving it.

## Local settings

`~/.zshrc.local` (interactive shells) and `~/.zprofile.local` (login shells) are optional, private files outside this repository. Put credentials and machine-specific environment variables there. Put local shell functions in `functions/*.zsh` inside this repository: for example, `functions/chatgpt.zsh`, `functions/codex.zsh` and `functions/proxy.zsh`. The entire `functions/` directory is ignored by Git; installation creates it and copies missing defaults from `templates/functions/`. Existing local function files are never overwritten. Files are sourced alphabetically after `.zshrc.local`. An absent or empty directory is valid. `move_to_trash` and its `rm` alias are seeded into `functions/move_to_trash.zsh`; the starter template is tracked, while the active copy is local. Changes to templates do not update an existing local copy. Transfer them separately and securely if needed. Do not commit SSH/GPG keys, password stores, history or tokens.

Node/NVM, Bun, Rust, TeX, Yandex Cloud, Docker and OpenVPN are optional and installed separately. Existing installations are picked up conditionally. `PYTHONBREAKPOINT=pudb.set_trace` requires `pudb` in the Python environment where it is used. Private proxy commands may also require `pass` and local helper scripts; these are not distributed here.

The Powerlevel10k configuration is included. Use a Nerd Font in the terminal for its symbols, or run `p10k configure` to adjust the prompt. Ghostty keybindings and shell integration are included; fonts and the Ghostty application are installed separately.

## Deleting files

The interactive `rm` alias moves files to `~/.trash`, preserving the previous workflow. This is not Finder Trash and is not an implementation of all `rm` flags: flags are ignored, and `--` permits names starting with a dash. Missing files produce an error. Use `command rm` for the real command when its exact semantics are needed.

## Neovim

Neovim's configuration remains in its separate repository:

```sh
git clone git@github.com:ValiaIsNotProgrammer/nvim_config.git ~/.config/nvim
```

Only do this when the destination does not already contain a configuration. Neovim plugins and language servers have their own installation requirements.

## Ghostty

`ghostty/config` holds the shared configuration. Installation links it to `${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config`. The legacy filename is also supported by newer Ghostty versions. Other default config files (`config.ghostty` and both macOS Application Support filenames) are backed up and removed from their active locations to avoid later settings overriding this file. Backups have separate `ghostty-*` filenames. Review them for settings to keep. Reload Ghostty using Command+Shift+comma, or restart it.

## Updating an existing Mac

```sh
cd ~/projects/dotfiles
git pull --ff-only
bash bootstrap.sh --brew --nvim --dry-run
bash bootstrap.sh --brew --nvim
# If the Neovim directory is already a checkout of nvim_config:
git -C ~/.config/nvim pull --ff-only
bash doctor.sh
exec zsh -l
```

After updating Neovim configuration, restart Neovim. LuaRocks and unused Node/Python/Ruby remote-plugin providers are disabled in `nvim_config`; this does not disable LSP or Python project environments. If you add plugins requiring those hosts, enable and install the appropriate host. `doctor.sh` does not start Neovim, modify files, fetch repositories or install tools. It checks executable availability, Neovim's minimum version, config links, shell plugin entrypoints and presence of key Neovim plugin directories. Language-server and parser checks remain in `:checkhealth` after opening the corresponding source file.
