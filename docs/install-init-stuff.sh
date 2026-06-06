brew install opera-gx alt-tab ghostty bat bat-extras colima raycast fzf lazygit tmux neovim gh battery git-delta zoxide cargo-binstall ripgrep


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

command -v rustup >/dev/null 2>&1 || curl https://sh.rustup.rs -sSf | sh -s -- -y
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

#dont worry, the required ~/.cargo/config.toml shuold already be there, from the config setup
cargo binstall sccache
#install broot with nice compiler options
cargo install broot --locked --features clipboard
