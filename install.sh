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
for name in .zshenv .zprofile .zshrc .p10k.zsh; do
  source_file="$repo_dir/zsh/$name"
  target_file="$HOME/$name"
  if [[ -L "$target_file" && "$(readlink "$target_file")" == "$source_file" ]]; then
    printf 'EXISTS: correct link %s\n' "$target_file"
    continue
  fi
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    printf 'BACKUP: %s -> %s/%s\n' "$target_file" "$backup_dir" "$name"
    if ! $dry_run; then
      mkdir -p "$backup_dir"
      mv "$target_file" "$backup_dir/$name"
    fi
  fi
  printf 'LINK: %s -> %s\n' "$target_file" "$source_file"
  if ! $dry_run; then ln -s "$source_file" "$target_file"; fi
done
if ! $dry_run; then printf 'Done. Restart your terminal to apply the configuration.\n'; fi
