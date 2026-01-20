#!/usr/bin/env bash
set -euo pipefail

# Search for all directories containing flakes
mapfile -t flake_dirs < <(find . -name "flake.nix" -exec dirname {} + | sort -u)

for flake_dir in "${flake_dirs[@]}"; do
	echo "Updating flake in: $flake_dir"
	nix flake update --flake "$flake_dir" --commit-lock-file --option commit-lock-file-summary "flake: update $flake_dir/flake.lock"
done
