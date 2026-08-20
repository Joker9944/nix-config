#!/usr/bin/env bash

# Regenerate the vendored tinted-theming schemes. $SCHEMES_SRC is injected by the
# packaged wrapper (writeShellApplication) from the locked flake input.

# The vendored tree is written into the working copy, not the store.
cd "$(git rev-parse --show-toplevel)/apps/nix-schemes" || exit 1

vendor_dir="$PWD/vendor/schemes"

rm -rf "$vendor_dir"

# `base*` skips upstream's tinted8, whose shape this flake does not model;
# `*.yaml` skips the one stray `.yml`.
for dir in "$SCHEMES_SRC"/base*/; do
	scheme_system="$(basename "$dir")"
	mkdir -p "$vendor_dir/$scheme_system"

	for file in "$dir"*.yaml; do
		yaml2nix "$file" >"$vendor_dir/$scheme_system/$(basename "$file" .yaml).nix"
	done
done

treefmt "$vendor_dir"
