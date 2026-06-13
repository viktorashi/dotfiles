brew install opera-gx alt-tab ghostty bat bat-extras colima docker docker-compose docker-credential-helper raycast fzf tmux neovim gh battery git-delta zoxide cargo-binstall ripgrep fd just

#cu docker compose
mkdir -p ~/.docker/cli-plugins && ln -sfn /opt/homebrew/bin/docker-compose ~/.docker/cli-plugins/docker-compose


curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
curl -fsSL https://get.pnpm.io/install.sh | sh -


command -v rustup >/dev/null 2>&1 || curl https://sh.rustup.rs -sSf | sh -s -- -y
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
rustup update
rustup component add rust-analyzer
rustup component add rustfmt

#il folosesti dupa cu cargo install-update -a
cargo binstall cargo-update
cargo binstall just-lsp

#nu-i bai, the required ~/.cargo/config.toml shuold already be there, from the config setup
cargo binstall sccache
#install broot with nice compiler options
cargo install broot --locked --features clipboard
