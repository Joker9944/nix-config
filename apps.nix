{
  lib,
  pkgs,
  system,
  ...
}:
{
  cspell = {
    type = "app";
    program = lib.getExe pkgs.cspell;
    inherit (pkgs.cspell) meta;
  };

  dconf-editor = {
    type = "app";
    program = lib.getExe pkgs.dconf-editor;
    inherit (pkgs.dconf-editor) meta;
  };

  gnome-tweaks = {
    type = "app";
    program = lib.getExe pkgs.gnome-tweaks;
    inherit (pkgs.gnome-tweaks) meta;
  };

  home-manager = {
    type = "app";
    program = lib.getExe pkgs.home-manager;
    inherit (pkgs.home-manager) meta;
  };

  krank-tree = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "krank-tree";

        text = ''
          cd "$(git rev-parse --show-toplevel)"

          # krank only matches /issues/<n>; /pull/ and /discussions/ links are silently skipped
          invisible=$(git ls-files -z |
            xargs -0 grep -nE 'github\.com/[^/ ]+/[^/ ]+/(pull|discussions)/[0-9]+' |
            grep -v 'krank:ignore-line' || true)
          if [ -n "$invisible" ]; then
            echo "warning: invisible to krank, use the /issues/ form (GitHub redirects it):"
            echo "$invisible"
            echo
          fi

          args=()
          if [ -n "''${GITHUB_TOKEN:-}" ]; then
            args+=(--issuetracker-githubkey "$GITHUB_TOKEN")
          fi

          mapfile -d "" -t files < <(git ls-files -z)
          krank "''${args[@]}" "''${files[@]}"
        '';

        runtimeInputs = with pkgs; [
          git
          krank
        ];
      }
    );
    meta.description = "Reports the status of issue tracker links in this flake";
  };

  update-packages = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "update-packages";

        text =
          let
            packages = [
              "File-MimeInfo"
            ];
          in
          lib.pipe packages [
            (lib.map (
              package: "nix-update ${package} --override-filename ./pkgs/${package}.nix --flake --commit"
            ))
            lib.concatLines
          ];

        runtimeInputs = with pkgs; [ nix-update ];
      }
    );
    meta.description = "Updates packages from this flake";
  };

  test-lib = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "test-lib";

        text = ''
          nix build .#checks.${system}.libTests --no-link "$@"
        '';
      }
    );
    meta.description = "Run lib tests";
  };

  obfuscate = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "obfuscate";

        text = ''
          if [ $# -ne 2 ]; then
            echo "Usage: obfuscate <mask> <string>"
            exit 1
          fi

          mask="$1"
          str="$2"

          nix eval --impure --raw --expr "builtins.toJSON ((builtins.getFlake \"$PWD\").lib.obfuscation.obfuscate $mask \"$str\")"
          echo
        '';
      }
    );
    meta.description = "Obfuscate a string using XOR with a mask";
  };
}
