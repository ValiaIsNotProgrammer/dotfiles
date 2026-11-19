#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")" && pwd)"
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --dry-run|--dry-install) dry_run=true ;;
    -h|--help) printf 'Usage: bash install.sh [--dry-run]\n'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
if $dry_run; then printf 'DRY RUN: configuration changes only listed below.\n'; fi
if [[ ! -d "$repo_dir/functions" ]]; then
  printf 'CREATE DIRECTORY: %s/functions\n' "$repo_dir"
  if ! $dry_run; then mkdir -p "$repo_dir/functions"; fi
fi
for template_file in "$repo_dir"/templates/functions/*.zsh; do
  local_file="$repo_dir/functions/$(basename "$template_file")"
  if [[ -e "$local_file" || -L "$local_file" ]]; then
    printf 'KEEP: %s\n' "$local_file"
  else
    printf 'COPY TEMPLATE: %s -> %s\n' "$template_file" "$local_file"
    if ! $dry_run; then cp "$template_file" "$local_file"; fi
  fi
done
backup_dir="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)-$$"
link_config() {
  local source_file="$1" target_file="$2" backup_name="$3"
  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    printf 'EXISTS: correct link %s\n' "$target_file"
    return
  fi
  backup_config "$target_file" "$backup_name"
  printf 'LINK: %s -> %s\n' "$target_file" "$source_file"
  if ! $dry_run; then
    mkdir -p "$(dirname "$target_file")"
    ln -s "$source_file" "$target_file"
  fi
}
backup_config() {
  local target_file="$1" backup_name="$2"
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    printf 'BACKUP: %s -> %s/%s\n' "$target_file" "$backup_dir" "$backup_name"
    if ! $dry_run; then
      mkdir -p "$backup_dir"
      mv "$target_file" "$backup_dir/$backup_name"
    fi
  fi
}
for name in .zshenv .zprofile .zshrc .p10k.zsh; do
  link_config "$repo_dir/zsh/$name" "$HOME/$name" "$name"
done
# Ghostty reads multiple paths; keep one canonical config to avoid overrides.
ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
backup_config "$ghostty_dir/config.ghostty" ghostty-xdg-config.ghostty
if [[ "$(uname -s)" == Darwin ]]; then
  ghostty_mac="$HOME/Library/Application Support/com.mitchellh.ghostty"
  backup_config "$ghostty_mac/config" ghostty-macos-config
  backup_config "$ghostty_mac/config.ghostty" ghostty-macos-config.ghostty
fi
link_config "$repo_dir/ghostty/config" "$ghostty_dir/config" ghostty-xdg-config
if ! $dry_run; then printf 'Done. Restart your terminal to apply the configuration.\n'; fi
