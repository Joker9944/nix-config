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
      customTypes = flake.lib.libSchemes.types;
    in
    {
      source = mkOption {
        type = types.nullOr (
          types.attrTag {
            scheme = mkOption {
              type = types.submodule {
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
                      The color scheme slug from tinted-theming/schemes.
                    '';
                  };
                };
              };
              description = ''
                Selects a color scheme from the tinted-theming/schemes repository.
                Specify the system (base16 or base24) and the scheme slug to use.
              '';
            };

            override = mkOption {
              type = customTypes.scheme;
              description = ''
                Provides a custom scheme directly, bypassing all sources.
              '';
            };
          }
        );
        default = null;
        description = ''
          The source for the color scheme. Exactly one tag must be set.
        '';
      };

      transformers = mkOption {
        type = types.listOf customTypes.transformer;
        default = [ ];
        description = ''
          Functions that modify the scheme before it becomes available as `schemes.scheme`.
          Common uses include adding custom colors, converting base16 to base24, or
          adding accent colors from other modules like `schemes.gtk.accentTransformer`.
          Some built-in transformers are available in `libSchemes.transformers`.
        '';
      };

      scheme = mkOption {
        type = types.nullOr customTypes.scheme;
        readOnly = true;
        description = ''
          The final computed scheme after applying all transformers.
          This is the scheme that other modules should use for theming.
        '';
      };
    };

  config =
    let
      cfg = config.schemes;

      tintedThemingScheme =
        flake.schemes.${cfg.source.scheme.system}.${cfg.source.scheme.slug}.convert
          pkgs;

      scheme =
        if cfg.source == null then
          null
        else if cfg.source ? scheme then
          tintedThemingScheme
        else
          cfg.source.override;

      transformedScheme = lib.foldl (
        scheme: transformer: scheme.transform transformer
      ) scheme cfg.transformers;
    in
    {
      schemes.scheme = if scheme == null then null else transformedScheme;
    };
}
