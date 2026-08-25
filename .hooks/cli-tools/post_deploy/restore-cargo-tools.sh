#!/bin/sh
set -eu

command -v cargo >/dev/null 2>&1 || exit 0

dotfiles_root=${DOTFILES:-"$HOME/.dotfiles"}
cargo_home=${CARGO_HOME:-"$HOME/.cargo"}

while IFS= read -r line; do
  case "$line" in "\""*) ;; *) continue ;; esac

  key=${line#\"}
  key=${key%%\" = *}
  package=${key%% *}
  remainder=${key#* }
  version=${remainder%% *}
  source=${key##* (}
  source=${source%)}
  bins=${line#* = [}
  bins=${bins%]}
  bins=$(printf '%s' "$bins" | tr -d '" ')

  missing=false
  old_ifs=$IFS
  IFS=,
  for bin in $bins; do
    [ -x "$cargo_home/bin/$bin" ] || missing=true
  done
  IFS=$old_ifs
  "$missing" || continue

  case "$source" in
    registry+*)
      if [ "$package" = cargo-binstall ] || ! command -v cargo-binstall >/dev/null 2>&1; then
        cargo install --locked --force --version "$version" "$package"
      else
        cargo binstall --no-confirm --force "$package@$version"
      fi
      ;;
    path+file://*)
      package_path=${source#path+file://}
      [ -d "$package_path" ] || {
        echo "Cargo package path is unavailable; skipping $package: $package_path" >&2
        continue
      }
      cargo install --locked --force --path "$package_path"
      ;;
    git+*)
      git_source=${source#git+}
      cargo install --locked --force --git "${git_source%%[?#]*}" --rev "${git_source##*#}" "$package"
      ;;
    *) echo "Unknown Cargo source; skipping $package: $source" >&2 ;;
  esac
done < "$dotfiles_root/files/cargo/crates.toml"
