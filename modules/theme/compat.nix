{ inputs, flake, ... }:
{
  _class,
  config,
  ...
}:
let
  cfg = config.custom.theme;
in
flake.lib.modules.mkClassModule _class {
  nixos = {
    imports = [ inputs.nix-schemes.nixosModules.default ];

    config = {
      schemes.regreet = {
        inherit (cfg.gtk) accent;

        accents.mode = if cfg.gtk.uniformAccents then "uniform" else "palette";
      };
    };
  };

  homeManager = {
    imports = [ inputs.nix-schemes.homeModules.default ];

    config = {
      fonts.fontconfig.defaultFonts = {
        monospace = [
          cfg.fonts.terminal.name
          cfg.fonts.monospace.name
        ];
        emoji = [ cfg.fonts.emoji.name ];
      };

      schemes.gtk = {
        inherit (cfg.gtk) accent;

        accents.mode = if cfg.gtk.uniformAccents then "uniform" else "palette";
      };
    };
  };
}
