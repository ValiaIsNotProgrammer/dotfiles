# Preserve the existing private trash location (not macOS Finder Trash).
move_to_trash() {
  local arg base target
  local -i result=0 suffix=0 options=1
  command mkdir -p -- "$HOME/.trash" || return
  for arg in "$@"; do
    if (( options )); then
      if [[ "$arg" == -- ]]; then options=0; continue; fi
      [[ "$arg" == -* ]] && continue
    fi
    if [[ ! -e "$arg" && ! -L "$arg" ]]; then
      print -u2 -- "trash: no such file: $arg"
      result=1
      continue
    fi
    if [[ "${arg:A}" == / || "${arg:A}" == "$HOME" || "${arg:A}" == "$HOME/.trash" || "${arg:t}" == . || "${arg:t}" == .. ]]; then
      print -u2 -- "trash: refusing unsafe target: $arg"
      result=1
      continue
    fi
    base="${arg:t}"
    target="$HOME/.trash/$base"
    suffix=0
    while [[ -e "$target" || -L "$target" ]]; do
      (( ++suffix ))
      target="$HOME/.trash/$base.$suffix"
    done
    command mv -- "$arg" "$target" || result=1
  done
  return $result
}

alias rm=move_to_trash
