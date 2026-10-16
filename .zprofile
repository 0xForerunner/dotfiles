# Homebrew supports Apple Silicon, Intel Macs, and Linux.
if (( $+commands[brew] )); then
  eval "$(brew shellenv)"
else
  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [[ -x "$brew_path" ]]; then
      eval "$("$brew_path" shellenv)"
      break
    fi
  done
  unset brew_path
fi

typeset -U path
path=("$HOME/.local/bin" "$HOME/.elan/bin" $path)
export PATH
