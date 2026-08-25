# mac

# keychain-backed ssh keys (macOS-only ssh-add flag)
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi
ssh-add --apple-use-keychain ~/.ssh/id_ed25519 > /dev/null 2>&1
ssh-add --apple-use-keychain ~/.ssh/id_rsa_backup > /dev/null 2>&1

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
