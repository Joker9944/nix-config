{ flake }:
{ lib, ... }:
flake.lib.mkDefaultModule
  {
    dir = ./.;
    args = { inherit flake; };
  }
  {
    options.programs.regreet =
      let
        inherit (lib) mkOption types;
      in
      {
        compositor = mkOption {
          type = types.enum [
            "cage"
            "hyprland"
          ];
          default = "cage";
          description = ''
            Which compositor should be used to run regreet.
          '';
        };
      };
  }
