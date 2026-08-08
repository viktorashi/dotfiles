#!/bin/sh
# Enable every deployed user unit that declares an [Install] section.
set -e
command -v systemctl >/dev/null || exit 0
systemctl --user daemon-reload
for unit in "$HOME"/.config/systemd/user/*.path "$HOME"/.config/systemd/user/*.service \
            "$HOME"/.config/systemd/user/*.socket "$HOME"/.config/systemd/user/*.timer; do
	[ -f "$unit" ] || continue
	grep -q '^\[Install\]' "$unit" || continue
	systemctl --user enable --now "$(basename "$unit")"
done
