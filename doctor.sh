#!/bin/bash
# Read-only checks: never start Neovim, install plugins or fetch repositories.
set -uo pipefail
repo_dir="$(cd "$(dirname "$0")" && pwd)"
source "$repo_dir/lib/homebrew.sh"
errors=0
warnings=0
ok() { printf 'OK: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; warnings=$((warnings + 1)); }
fail() { printf 'ERROR: %s\n' "$*"; errors=$((errors + 1)); }
if brew_bin="$(dotfiles_find_brew)"; then
  ok "Homebrew: $brew_bin"
  eval "$("$brew_bin" shellenv)"
else
  warn 'Homebrew not found; optional, needed only for bootstrap --brew.'
fi
for tool in git zsh nvim rg; do
  if command -v "$tool" >/dev/null; then
    ok "$tool: $(command -v "$tool")"
  else
    fail "$tool missing; rg is required for live grep, nvim for editing. Git is installed separately."
  fi
done
if command -v fd >/dev/null; then ok 'fd available'; else warn 'fd missing; enhanced file search unavailable (bootstrap --brew).'; fi
if command -v nvim >/dev/null; then
  nvim_version="$(nvim --version | head -n 1)"
  if [[ "$nvim_version" =~ v([0-9]+)\.([0-9]+) ]] && { (( BASH_REMATCH[1] > 0 )) || (( BASH_REMATCH[2] >= 11 )); }; then
    ok "$nvim_version supports the configured LSP API"
  else
    fail "Neovim >= 0.11 required; found $nvim_version"
  fi
fi
check_link() {
  if [[ -L "$1" && "$(readlink "$1")" == "$2" ]]; then ok "link $1"; else fail "link $1 is not configured; run bash install.sh"; fi
}
for name in .zshenv .zprofile .zshrc .p10k.zsh; do
  check_link "$HOME/$name" "$repo_dir/zsh/$name"
done
for entry in oh-my-zsh.sh custom/themes/powerlevel10k/powerlevel10k.zsh-theme custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh custom/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh; do
  if [[ -r "$HOME/.oh-my-zsh/$entry" ]]; then ok "$entry"; else fail "missing $entry; run bash bootstrap.sh"; fi
done
if [[ -r "$repo_dir/functions/move_to_trash.zsh" ]]; then ok 'local move_to_trash exists'; else warn 'local move_to_trash missing; run bash install.sh'; fi
ghostty_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
check_link "$ghostty_dir/config" "$repo_dir/ghostty/config"
for extra in "$ghostty_dir/config.ghostty" "$HOME/Library/Application Support/com.mitchellh.ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"; do
  if [[ -e "$extra" || -L "$extra" ]]; then warn "additional Ghostty config may override settings: $extra"; fi
done
if command -v ghostty >/dev/null || [[ -x /Applications/Ghostty.app/Contents/MacOS/ghostty || -x "$HOME/Applications/Ghostty.app/Contents/MacOS/ghostty" ]]; then
  ok 'Ghostty installed'
else
  warn 'Ghostty app not found; config is ready, install the app separately.'
fi
nvim_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
if [[ -r "$nvim_dir/init.lua" ]]; then ok 'Neovim configuration exists'; else warn 'Neovim configuration missing; use bootstrap --nvim'; fi
nvim_data="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
for plugin in lazy.nvim telescope.nvim render-markdown.nvim; do
  if [[ -d "$nvim_data/lazy/$plugin" ]]; then ok "Neovim plugin $plugin"; else warn "plugin $plugin missing; start Neovim and use :Lazy restore"; fi
done
printf '\nResult: %s errors, %s warnings.\n' "$errors" "$warnings"
printf 'Language-specific parsers and LSP servers: open a source file and run :checkhealth in Neovim.\n'
(( errors == 0 ))
