# Shared by Bash installers and the Zsh login configuration.
dotfiles_find_brew() {
  local candidate
  candidate="$(command -v brew 2>/dev/null)" || candidate=''
  if [ -n "$candidate" ] && [ -x "$candidate" ]; then
    printf '%s\n' "$candidate"
    return 0
  fi
  for candidate in "$HOME/.homebrew/bin/brew" /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}
