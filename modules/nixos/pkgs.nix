_:
{
  lib,
  config,
  custom,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.custom.pkgs = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          input = mkOption {
            type = types.raw;
            example = lib.literalExpression "inputs.nixpkgs-unstable";
            description = ''
              Nixpkgs flake input to instantiate.
            '';
          };
          config = mkOption {
            type = types.attrs;
            default = config.nixpkgs.config;
            description = ''
              Nixpkgs config. Defaults to the base nixpkgs config.
            '';
          };
          overlays = mkOption {
            type = types.listOf types.raw;
            default = config.nixpkgs.overlays;
            description = ''
              Overlays to apply. Defaults to the base nixpkgs overlays.
            '';
          };
        };
      }
    );
    default = { };
    example = lib.literalExpression ''
      {
        pkgs-unstable.input = inputs.nixpkgs-unstable;
        pkgs-hyprland.input = inputs.hyprland.inputs.nixpkgs;
      }
    '';
    description = ''
      Additional nixpkgs instances exposed as module arguments with the same name as the attribute key.
    '';
  };

  config._module.args = lib.mapAttrs (
    _: pkgCfg:
    import pkgCfg.input {
      inherit (pkgCfg) config overlays;
      localSystem = custom.config.system;
    }
  ) config.custom.pkgs;
}
