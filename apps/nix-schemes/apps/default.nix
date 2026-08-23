{
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
{
  test-lib = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellScriptBin "test" ''
        nix build .#checks.${system}.libTests --no-link "$@"
      ''
    );
    meta.description = "Run lib tests";
  };

  preview-cursors = {
    type = "app";
    program = lib.getExe (
      pkgs.writers.writePython3Bin "preview-cursors" {
        libraries = [ pkgs.python3Packages.pillow ];
        # `libraries` covers imports; a renderer reached through `subprocess` needs PATH.
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [ pkgs.resvg ])
        ];
      } (builtins.readFile ./files/preview-cursors.py)
    );
    meta.description = "Tile a compiled cursor theme into one PNG";
  };

  update-cursor-templates = {
    type = "app";
    program = lib.getExe (
      pkgs.writers.writePython3Bin "update-cursor-templates" {
        # The source is the locked input, not something a caller picks; `git` stays
        # ambient, per the rule every working-copy script here follows.
        makeWrapperArgs = [
          "--add-flags"
          "${inputs.breeze}"
        ];
      } (builtins.readFile ./files/vendor-cursors.py)
    );
    meta.description = "Regenerate the vendored Breeze cursor templates";
  };

  update-schemes = {
    type = "app";
    program = lib.getExe (
      pkgs.writeShellApplication {
        name = "update-schemes";
        runtimeInputs = with pkgs; [
          yaml2nix
          nixfmt-tree
        ];
        runtimeEnv.SCHEMES_SRC = inputs.schemes;
        text = builtins.readFile ./files/update-schemes.sh;
      }
    );
    meta.description = "Regenerate the vendored tinted-theming schemes";
  };
}
