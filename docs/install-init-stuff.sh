brew install opera-gx alt-tab ghostty bat bat-extras colima raycast fzf lazygit tmux neovim gh battery git-delta zoxide cargo-binstall

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install lts
nvm use --lts

command -v rustup >/dev/null 2>&1 || curl https://sh.rustup.rs -sSf | sh -s -- -y
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
cargo binstall sccache

cat >> $HOME/.cargo/config.toml <<- EOM
[build]
rustc-wrapper = "$(which sccache)"
EOM

#install broot with nice compiler options
if [ ! -d ~/broot ]; then
  git clone https://github.com/Canop/broot ~/broot
fi
( cd ~/broot && cargo install --locked --features clipboard --path . ) || brew install broot
