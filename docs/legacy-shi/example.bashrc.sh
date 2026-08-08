# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions

alias ll='ls -lsa'
alias cl='clear'
alias iv='file=$(find . -type f 2>/dev/null | fzy) && [ -n "$file" ] && vim "$file"'

export TERM=xterm-ghostty

# --- FZY History Search ---

_fzy_history() {
  # 1. Grab the shell history.
  # 2. Sort it in reverse numerically so your newest commands are at the top.
  # 3. Use sed to strip out the leading history numbers.
  # 4. Pipe the clean list into fzy for you to search.
  local cmd=$(history | sort -nr | sed 's/^ *[0-9]* *//' | fzy)

  # If you selected a command (and didn't hit escape), push it to the history stack.
  if [ -n "$cmd" ]; then
    history -s "$cmd"
  fi
}

# Bind our custom function to a hidden, background keystroke (Ctrl-X, 1)
bind -x '"\C-x1": _fzy_history'

# Bind Ctrl-R to a macro that:
# 1. Clears your current prompt (\C-a\C-k)
# 2. Executes our hidden fzy function (\C-x1)
# 3. Presses the "Up Arrow" (\C-p) to fetch the command we just pushed into history
bind '"\C-r": "\C-a\C-k\C-x1\C-p"'
