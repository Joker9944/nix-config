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
