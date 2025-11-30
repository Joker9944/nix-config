{
  lib,
  config,
  ...
}:
{
  options.custom.nixpkgsCompat =
    let
      inherit (lib) mkOption literalExpression types;
    in
    {
      allowUnfreePackages = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = literalExpression ''
          [
            "1password"
            "1password-cli"
          ]
        '';
        description = ''
          Unfree packages which should be allowed.
        '';
      };

      allowUnfreeLicenses = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = literalExpression ''
          [
            "CUDA EULA"
            "cuDNN EULA"
          ]
        '';
        description = ''
          Unfree package licenses which should be allowed.
        '';
      };

      allowUnfreePredicates = mkOption {
        type = types.listOf (types.functionTo types.bool);
        default = [ ];
        example = literalExpression "[ (pkg: builtins.elem (lib.getName pkg) [ \"1password\" ]) ]";
        description = ''
          Predicates to match unfree pkgs which should be allowed, will be combined with logical OR.
        '';
      };

      additionalNixpkgsInstances = mkOption {
        type = types.attrsOf types.attrs;
        default = { };
        example = literalExpression ''
          {
            pkgs-unstable = inputs.nixpkgs-unstable;
            pkgs-hyprland = inputs.hyprland.inputs.nixpkgs;
          }
        '';
        description = ''
          Additional nixpkgs instances that should be made available as module args with the same config as base `pkgs`.
        '';
      };
    };

  config =
    let
      cfg = config.custom.nixpkgsCompat;

      allowUnfreePackagesByName = pkg: lib.elem (lib.getName pkg) cfg.allowUnfreePackages;

      isLicenseAllowed = license: lib.elem license cfg.allowUnfreeLicenses;
      getLicenses =
        pkg:
        if (lib.isList pkg.meta.license) then
          lib.map (license: license.shortName) pkg.meta.license
        else
          [ pkg.meta.license.shortName ];

      allowUnfreePackagesByLicense = pkg: lib.all isLicenseAllowed (getLicenses pkg);
    in
    {
      custom.nixpkgsCompat.allowUnfreePredicates = [
        allowUnfreePackagesByName
        allowUnfreePackagesByLicense
      ];

      nixpkgs.config.allowUnfreePredicate =
        pkg: lib.any (predicate: predicate pkg) cfg.allowUnfreePredicates;

      _module.args = lib.mapAttrs (
        _: nixpkgsInstance:
        import nixpkgsInstance {
          inherit (config.nixpkgs) config overlays;
          localSystem = config.nixpkgs.hostPlatform;
        }
      ) cfg.additionalNixpkgsInstances;
    };
}
