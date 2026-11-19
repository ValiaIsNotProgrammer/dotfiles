if [[ -n "$GHOSTTY_RESOURCES_DIR" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR=nvim VISUAL=nvim
export PYTHONBREAKPOINT=pudb.set_trace
KEYTIMEOUT=1

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-vim-mode)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gtlg='git log -G"def\s+login"'
alias docker-compose='docker compose'
if [[ -x '/Applications/OpenVPN Connect/OpenVPN Connect.app/Contents/MacOS/OpenVPN Connect' ]]; then
  alias openvpn='"/Applications/OpenVPN Connect/OpenVPN Connect.app/Contents/MacOS/OpenVPN Connect"'
fi

bindkey '^ ' up-line-or-beginning-search
bindkey -M viins '^J' history-beginning-search-backward-end
bindkey -M vicmd '^J' history-beginning-search-backward-end
bindkey -M viins '^K' history-beginning-search-forward-end
bindkey -M vicmd '^K' history-beginning-search-forward-end
MODE_CURSOR_VIINS="#B3B1AD blinking bar"
MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #B3B1AD"
MODE_CURSOR_VICMD="#B3B1AD"
MODE_CURSOR_SEARCH="#B3B1AD steady underline"
MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #B3B1AD"

# Optional tools: their absence must not break a fresh Mac.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" $path)
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
[[ -d /Library/TeX/texbin ]] && path+=(/Library/TeX/texbin)
[[ -r "$HOME/yandex-cloud/path.bash.inc" ]] && source "$HOME/yandex-cloud/path.bash.inc"
[[ -r "$HOME/yandex-cloud/completion.zsh.inc" ]] && source "$HOME/yandex-cloud/completion.zsh.inc"

[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
