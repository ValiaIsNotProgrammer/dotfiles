#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")" && pwd)"
backup_dir="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)-$$"
for name in .zshenv .zprofile .zshrc .p10k.zsh; do
  source_file="$repo_dir/zsh/$name"
  target_file="$HOME/$name"
  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    continue
  fi
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    mkdir -p "$backup_dir"
    mv "$target_file" "$backup_dir/$name"
  fi
  ln -s "$source_file" "$target_file"
  printf 'Linked %s\n' "$target_file"
done
if [[ -d "$backup_dir" ]]; then printf 'Backup: %s\n' "$backup_dir"; fi
printf 'Done. Restart your terminal to apply the configuration.\n'
