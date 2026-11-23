#!/usr/bin/env bash
set -euo pipefail

# Declarative Git settings live in files/git/config (linked to ~/.config/git/config).
# This hook manages only the imperative keyrings/trust state.

# Install archived verification keys. These are public keys only; signing still
# requires the corresponding private key to be provisioned on this machine.
SIGNING_KEYS_DIR="$HOME/.dotfiles/files/certs-keys/git-signing"
if [ -d "$SIGNING_KEYS_DIR/openpgp" ]; then
	shopt -s nullglob
	openpgp_keys=("$SIGNING_KEYS_DIR/openpgp/"*.asc)
	shopt -u nullglob
	if [ ${#openpgp_keys[@]} -gt 0 ]; then
		gpg --batch --import "${openpgp_keys[@]}"

		# Read the primary fingerprints, rather than maintaining a second list.
		mapfile -t archived_openpgp_fingerprints < <(
			gpg --batch --show-keys --with-colons "${openpgp_keys[@]}" |
				awk -F: '$1 == "pub" { primary = 1; next } $1 == "fpr" && primary { print $10; primary = 0 }'
		)
		mapfile -t own_openpgp_fingerprints < <(
			gpg --batch --with-colons --list-secret-keys |
				awk -F: '$1 == "sec" { primary = 1; next } $1 == "fpr" && primary { print $10; primary = 0 }'
		)

		declare -A own_openpgp_key current_openpgp_ownertrust
		for fingerprint in "${own_openpgp_fingerprints[@]}"; do
			own_openpgp_key["$fingerprint"]=1
		done
		while IFS=: read -r fingerprint trust _; do
			current_openpgp_ownertrust["$fingerprint"]=$trust
		done < <(gpg --batch --export-ownertrust)

		# Colleagues' archived keys are marginal introducers. Our private keys are
		# ultimate. A manually selected full level for a public-only personal key
		# is left alone.
		openpgp_ownertrust=()
		for fingerprint in "${archived_openpgp_fingerprints[@]}"; do
			trust=4
			if [ "${own_openpgp_key[$fingerprint]:-}" = 1 ]; then
				trust=6
			elif [ "${current_openpgp_ownertrust[$fingerprint]:-}" = 5 ]; then
				continue
			fi
			openpgp_ownertrust+=("$fingerprint:$trust:")
		done
		if [ ${#openpgp_ownertrust[@]} -gt 0 ]; then
			printf '%s\n' "${openpgp_ownertrust[@]}" | gpg --batch --import-ownertrust
		fi
	fi
fi
