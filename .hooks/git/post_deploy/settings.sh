#! /bin/bash

git config --global alias.st status
git config --global alias.s status
git config --global alias.f fetch
git config --global alias.P push --replace-all
git config --global alias.p pull --replace-all
git config --global alias.c commit
git config --global alias.b branch
git config --global alias.co checkout
git config --global alias.sw switch
git config --global alias.a add
git config --global alias.d diff
git config --global alias.a add
git config --global alias.l log
git config --global alias.t tag
git config --global alias.m merge
git config --global pull.rebase true
# Keep background fetches from weakening implicit --force-with-lease checks.
git config --global push.useForceIfIncludes true

#sa scapam de line endingurile alea de kkt pe windows
git config --global core.autocrlf true

git config --global core.editor "vim"

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3
git config --global core.autocrlf input
git config --global delta.syntax-theme "Dracula"
git config --global delta.line-numbers true
git config --global delta.side-by-side false
git config --global http.postBuffer 524288000

# kktu asta e sa imi fac conflictele misto
# ti-l pui in
# ~/.gitconfig
# [diff]
#     tool = vimdiff
# [merge]
#     tool = vimdiff
#     conflictstyle = zdiff3
# [mergetool "vimdiff"]
#     cmd = nvim -d $LOCAL $BASE $REMOTE $MERGED \
#           -c '$wincmd w' -c 'wincmd J'

git config --global core.excludesfile "$HOME/.config/git/ignore"

# The default work identity is enabled manually on arch-wsl only.
# See files/git/README.md; deploying public keys does not provide a signing key.

# Dynamic identity for viktorashi repos (any repo having a remote pointing to viktorashi on github)
git config --global 'includeIf.hasconfig:remote.*.url:*://viktorashi@github.com/**.path' "$HOME/.config/git/config-viktorashi"
git config --global 'includeIf.hasconfig:remote.*.url:*://github.com/viktorashi/**.path' "$HOME/.config/git/config-viktorashi"
git config --global 'includeIf.hasconfig:remote.*.url:git@github.com:viktorashi/**.path' "$HOME/.config/git/config-viktorashi"
git config --global 'includeIf.hasconfig:remote.*.url:ssh://git@github.com/viktorashi/**.path' "$HOME/.config/git/config-viktorashi"

git config --global commit.gpgsign true

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

if [ -f "$SIGNING_KEYS_DIR/ssh/allowed_signers" ]; then
	git config --global gpg.ssh.allowedSignersFile "$SIGNING_KEYS_DIR/ssh/allowed_signers"
fi
