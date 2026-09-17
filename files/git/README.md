# Git identities

`config-viktorashi` selects the personal identity and signing key through the
remote-based includes installed by the Git hook.

`config-work` records the work identity and its current signing-key fingerprint.
On this arch-wsl machine only, `~/.gitconfig` includes it **before** the personal
conditional includes. That include is local machine state: no Dotter package,
machine profile or deployment hook enables it. Other machines must opt in only
after provisioning the corresponding private key.

Public key archives live in `../certs-keys/`. Importing a public key permits
verification; it does not enable signing. The Git post-deploy hook imports and
trusts the archived OpenPGP keys, then configures Git's SSH allowed-signers file.

Read identities, fingerprints and expiry dates directly from the public keys:

```sh
gpg --show-keys --with-fingerprint files/certs-keys/*.asc \
  files/certs-keys/git-signing/openpgp/*.asc
```
