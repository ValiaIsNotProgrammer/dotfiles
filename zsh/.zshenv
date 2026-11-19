# Keep non-interactive shells quiet; preserve first occurrence of each PATH entry.
typeset -U path PATH
path=("$HOME/.local/bin" $path)
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
