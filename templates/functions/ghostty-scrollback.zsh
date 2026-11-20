# Ghostty 1.2.x scrollback integration: file actions insert a raw temporary path.
# Recognize only Ghostty's owned temporary history/screen files; never eval input.
_ghostty_scrollback_open() {
  emulate -L zsh
  [[ $TERM_PROGRAM == ghostty ]] || return 0
  [[ ${_ghostty_scrollback_busy:-0} == 0 ]] || return 0
  local pattern='(/[^[:space:]]*/[A-Za-z0-9_-]{22}/(history|screen)\.txt)$'
  local MATCH
  local -a match mbegin mend
  [[ $LBUFFER =~ $pattern ]] || return 0
  local scrollback_file=$match[1]
  [[ -f "$scrollback_file" && -r "$scrollback_file" && -O "$scrollback_file" && ! -L "$scrollback_file" ]] || return 0
  local temp_root="${scrollback_file:A:h:h}"
  local expected_root="${TMPDIR:-/tmp}"
  [[ "$temp_root" == "${expected_root:A}" || "$temp_root" == /private/tmp || "$temp_root" == /tmp ]] || return 0
  (( $+commands[nvim] )) || return 0
  local -i _ghostty_scrollback_busy=1
  local saved_right=$RBUFFER
  local saved_left="${LBUFFER%"$scrollback_file"}"
  local saved_keymap=$KEYMAP
  LBUFFER=$saved_left
  RBUFFER=$saved_right
  zle -I
  command nvim -R -n -i NONE "+setlocal buftype=nofile bufhidden=wipe noswapfile noundofile nomodifiable" +normal\ G -- "$scrollback_file" </dev/tty >/dev/tty 2>/dev/tty
  LBUFFER=$saved_left
  RBUFFER=$saved_right
  [[ -z "$saved_keymap" ]] || zle -K "$saved_keymap"
  zle reset-prompt
  return 0
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget -d line-pre-redraw _ghostty_scrollback_open 2>/dev/null
add-zle-hook-widget line-pre-redraw _ghostty_scrollback_open
