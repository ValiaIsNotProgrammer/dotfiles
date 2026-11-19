#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")" && pwd)"
dry_run=false
with_brew=false
with_nvim=false
source "$repo_dir/lib/homebrew.sh"
brew_bin="$(dotfiles_find_brew)" || brew_bin=''
if [[ -n "$brew_bin" ]]; then eval "$("$brew_bin" shellenv)"; fi
for arg in "$@"; do
  case "$arg" in
    --dry-run|--dry-install) dry_run=true ;;
    --brew) with_brew=true ;;
    --nvim) with_nvim=true ;;
    -h|--help) printf 'Usage: bash bootstrap.sh [--brew] [--nvim] [--dry-run]\nHomebrew packages are opt-in. Git is never installed.\n'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
if $dry_run; then printf 'DRY RUN: no files, packages or repositories will be changed.\n'; fi
if command -v git >/dev/null; then
  printf 'EXISTS: git (%s); managed externally\n' "$(command -v git)"
else
  printf 'MISSING: git; install Xcode Command Line Tools before cloning plugins.\n'
fi
if $with_brew; then
  if [[ -z "$brew_bin" ]]; then
    printf 'MISSING: Homebrew; install it separately from https://brew.sh\n'
    if ! $dry_run; then exit 1; fi
  fi
  while IFS= read -r formula; do
    [[ -n "$formula" ]] || continue
    if [[ -n "$brew_bin" ]] && HOMEBREW_NO_AUTO_UPDATE=1 "$brew_bin" list --versions "$formula" >/dev/null 2>&1; then
      printf 'EXISTS: brew package %s (no upgrade)\n' "$formula"
    else
      printf 'INSTALL: brew package %s\n' "$formula"
      if ! $dry_run; then HOMEBREW_NO_AUTO_UPDATE=1 "$brew_bin" install "$formula"; fi
    fi
  done < <(sed -n 's/^brew "\([^"]*\)".*$/\1/p' "$repo_dir/Brewfile")
else
  printf 'SKIP: Homebrew packages (use --brew to include them).\n'
fi
clone_missing() {
  if [[ -d "$2/.git" ]]; then
    printf 'EXISTS: %s (no update)\n' "$2"
  elif [[ -e "$2" || -L "$2" ]]; then
    printf 'CONFLICT: existing non-git path %s; resolve before installation.\n' "$2" >&2
    if ! $dry_run; then exit 1; fi
  else
    printf 'CLONE: %s -> %s\n' "$1" "$2"
    if ! $dry_run; then
      command -v git >/dev/null || { printf 'Git is required but will not be installed automatically.\n' >&2; exit 1; }
      git clone --depth=1 "$1" "$2"
    fi
  fi
}
clone_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
custom_dir="$HOME/.oh-my-zsh/custom"
clone_missing https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
clone_missing https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
clone_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
clone_missing https://github.com/softmoth/zsh-vim-mode.git "$custom_dir/plugins/zsh-vim-mode"
if $dry_run; then bash "$repo_dir/install.sh" --dry-run; else bash "$repo_dir/install.sh"; fi

if $with_nvim; then
  nvim_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  if [[ -e "$nvim_dir" || -L "$nvim_dir" ]]; then
    printf 'KEEP: existing Neovim configuration %s (not replaced or pulled automatically).\n' "$nvim_dir"
  else
    clone_missing https://github.com/ValiaIsNotProgrammer/nvim_config.git "$nvim_dir"
  fi
  printf 'Neovim: start nvim to install missing plugins; use :Lazy restore for locked versions.\n'
fi
for tool in nvim rg fd; do
  if command -v "$tool" >/dev/null; then
    printf 'AVAILABLE: %s\n' "$tool"
  elif [[ "$tool" == rg ]]; then
    printf 'MISSING: rg; live grep will not work until ripgrep is installed (use --brew).\n'
  else
    printf 'MISSING: %s; use --brew to install.\n' "$tool"
  fi
done
printf 'Run bash doctor.sh to verify the environment.\n'
