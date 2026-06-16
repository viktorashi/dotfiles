export git_dir="$HOME/.cfg/"
conf() { git --git-dir="${git_dir}" --work-tree="$HOME" "$@"; }
