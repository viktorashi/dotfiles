brew install opera-gx alt-tab ghostty bat bat-extras colima raycast fzf lazygit tmux neovim gh battery git-delta zoxide

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
nvm install lts
nvm use --lts

curl https://sh.rustup.rs -sSf | sh

( git clone https://github.com/Canop/broot ~/broot && cd ~/broot && cargo install --locked --features clipboard --path . && cd ../ && rm -rf ~/broot ) || brew install broot
