#!/usr/bin/env python3

import os
import re
import subprocess
from pathlib import Path


def find_flake_dirs() -> list[Path]:
    return sorted({p.parent for p in Path(".").rglob("flake.nix")})


def nix_eval_names(flake_dir: Path, attr: str) -> list[str]:
    result = subprocess.run(
        [
            "nix",
            "eval",
            "--raw",
            f"{flake_dir}#{attr}",
            "--apply",
            'x: builtins.concatStringsSep "\\n" (builtins.attrNames x)',
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return []
    return [name for name in result.stdout.splitlines() if name]


def count_dry_run_builds(installable: str) -> int:
    result = subprocess.run(
        ["nix", "build", "--dry-run", installable],
        capture_output=True,
        text=True,
    )
    output = result.stdout + result.stderr
    total = 0
    for match in re.finditer(r"(\d+) derivations? will be built", output):
        total += int(match.group(1))
    return total


def main():
    total = 0

    for flake_dir in find_flake_dirs():
        print(f"Scanning flake: {flake_dir}")

        for name in nix_eval_names(flake_dir, "nixosConfigurations"):
            installable = (
                f"{flake_dir}#nixosConfigurations.{name}.config.system.build.toplevel"
            )
            count = count_dry_run_builds(installable)
            total += count
            print(f"  nixosConfigurations.{name}: {count} derivations to build")

        for name in nix_eval_names(flake_dir, "homeConfigurations"):
            installable = f'{flake_dir}#homeConfigurations."{name}".activationPackage'
            count = count_dry_run_builds(installable)
            total += count
            print(f"  homeConfigurations.{name}: {count} derivations to build")

    print(f"Total derivations to build: {total}")

    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
        f.write(f"build_count={total}\n")


if __name__ == "__main__":
    main()
