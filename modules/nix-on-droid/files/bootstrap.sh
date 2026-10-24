#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

# Switch this device to a nix-on-droid host of a flake whose Nix and proot-static are newer than
# the installed ones. Rerun it after the app restart it may ask for.
#
# Usage: bootstrap.sh [<flake>#<host>]

target="${1:-github:Joker9944/nix-config#AM}"
attr="${target%%#*}#nixOnDroidConfigurations.${target#*#}"
nixpkgs="github:NixOS/nixpkgs/nixos-26.05"
features=(--extra-experimental-features 'nix-command flakes')
substituters=(
	--option extra-substituters https://nix-on-droid.cachix.org
	--option extra-trusted-public-keys 'nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU='
)

# The installed Nix may be too old to parse the flake, so a current one evaluates. It only
# evaluates: under an outdated proot-static its builds fail, so the installed Nix builds.
# Evaluation substitutes proot-static itself, which nix-on-droid references by store path.
evaluate() {
	nix "${features[@]}" shell "$nixpkgs#nix" "$nixpkgs#git" -c \
		nix "${features[@]}" eval --impure --raw "${substituters[@]}" "$attr.$1"
}

proot="$(evaluate config.environment.files.prootStatic)"
if [[ "$(sha256sum </bin/proot-static)" != "$(sha256sum <"$proot/bin/proot-static")" ]]; then
	cp "$proot/bin/proot-static" /bin/.proot-static.new
	chmod +x /bin/.proot-static.new
	echo "Staged a new proot-static. Close every session so the app exits, reopen it and rerun this."
	exit 0
fi

drv="$(evaluate activationPackage.drvPath)"
out="$(nix-store --realise "$drv" "${substituters[@]}")"
"$out/activate"
