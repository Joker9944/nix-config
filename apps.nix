{
  lib,
  pkgs,
  system,
  ...
}:
{
  cspell = {
    type = "app";
    program = lib.getExe pkgs.nodePackages.cspell;
    inherit (pkgs.nodePackages.cspell) meta;
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

  update-packages = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "update-packages";

        text =
          let
            packages = [
              "File-MimeInfo"
              "freelens"
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
