# Use the same Homebrew discovery as bootstrap and doctor.
() {
  source "${${(%):-%x}:A:h:h}/lib/homebrew.sh"
  local brew_bin
  if brew_bin="$(dotfiles_find_brew)"; then
    eval "$("$brew_bin" shellenv)"
  fi
  unfunction dotfiles_find_brew
}
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
