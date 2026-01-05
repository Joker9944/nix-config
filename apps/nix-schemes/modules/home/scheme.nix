flake:
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.schemes =
    let
      inherit (lib) mkOption types;
      customTypes = flake.lib.types;
    in
    {
      source = {
        scheme = mkOption {
          type = types.nullOr (
            types.submodule {
              options = {
                system = mkOption {
                  type = types.enum [
                    "base16"
                    "base24"
                  ];
                  description = ''
                    The color scheme system.
                  '';
                };

                slug = mkOption {
                  type = types.str;
                  example = "dracula";
                  description = ''
                    The color scheme slug from tinted-theming/schemes
                  '';
                };
              };
            }
          );
        };

        override = mkOption {
          type = types.nullOr customTypes.scheme;
          default = null;
          description = ''
            scheme override
          '';
        };
      };

      transformers = mkOption {
        type = types.listOf customTypes.transformer;
        default = [ ];
        description = ''
          transformers
        '';
      };

      scheme = mkOption {
        type = types.nullOr customTypes.scheme;
        readOnly = true;
      };
    };

  config =
    let
      cfg = config.schemes;

      tintedThemingScheme =
        flake.schemes.${cfg.source.scheme.system}.${cfg.source.scheme.slug}.convert
          pkgs;

      scheme =
        if cfg.source.override != null then
          cfg.source.override
        else if cfg.source.scheme != null then
          tintedThemingScheme
        else
          null;

      transformedScheme = lib.foldl (
        scheme: transformer: scheme.transform transformer
      ) scheme cfg.transformers;
    in
    {
      schemes.scheme = if scheme == null then null else transformedScheme;
    };
}
