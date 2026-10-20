#!/usr/bin/env bash
set -euo pipefail

# 1. Terminate any stuck pinentry processes
pkill -u "$USER" -x pinentry pinentry-gtk pinentry-curses pinentry-gnome3 pinentry-qt 2>/dev/null || true

# 2. Remove stale lock files left behind by interrupted or timed-out GPG sessions
rm -f "$HOME/.gnupg"/.#lk* 2>/dev/null || true

# 3. Restart gpg-agent to ensure a clean state
if systemctl --user is-active --quiet gpg-agent 2>/dev/null || command -v systemctl >/dev/null 2>&1; then
	systemctl --user restart gpg-agent 2>/dev/null || gpgconf --kill gpg-agent 2>/dev/null || true
else
	gpgconf --kill gpg-agent 2>/dev/null || true
fi

# 4. Attach gpg-agent to the current terminal
GPG_TTY="$(tty 2>/dev/null || true)"
export GPG_TTY
if [[ -n "$GPG_TTY" && "$GPG_TTY" != "not a tty" ]]; then
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
fi

# 5. Sign a dummy payload to trigger pinentry and prime the agent cache
echo "Priming GPG agent cache (please enter passphrase if prompted)..."
if echo "test" | gpg --clearsign >/dev/null; then
	echo "GPG key passphrase cached successfully for the next 24 hours."
else
	echo "Failed to sign test payload. Please check above for GPG errors." >&2
	exit 1
fi
