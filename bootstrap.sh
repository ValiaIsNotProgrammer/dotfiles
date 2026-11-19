#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")" && pwd)"
if ! command -v brew >/dev/null; then
  printf 'Install Homebrew first: https://brew.sh\n' >&2
  exit 1
fi
brew bundle --file="$repo_dir/Brewfile"
clone_missing() {
  if [[ ! -e "$2" ]]; then
    git clone --depth=1 "$1" "$2"
  elif [[ ! -d "$2/.git" ]]; then
    printf 'Existing non-git directory: %s; inspect it before continuing.\n' "$2" >&2
    exit 1
  fi
}
clone_missing https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
custom_dir="$HOME/.oh-my-zsh/custom"
clone_missing https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k"
clone_missing https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
clone_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
clone_missing https://github.com/softmoth/zsh-vim-mode.git "$custom_dir/plugins/zsh-vim-mode"
bash "$repo_dir/install.sh"
