_:
{ lib, config, ... }:
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
    };
}
