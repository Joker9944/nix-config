flake:
{
  lib,
  config,
  ...
}:
let
  libSchemes = flake.lib.libSchemes;
in
{
  options.schemes =
    let
      inherit (lib) mkOption types literalExpression;
      customTypes = libSchemes.types;

      colorRef = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = ''
          Colors keyed by the path they replace. A value either names a palette slot or
          is a hex string.
        '';
      };
    in
    {
      source = mkOption {
        type = types.nullOr (
          types.attrTag {
            tinted = mkOption {
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

            custom = mkOption {
              type = types.submodule {
                options = {
                  name = mkOption {
                    type = types.str;
                    description = ''
                      The scheme name.
                    '';
                  };

                  author = mkOption {
                    type = types.str;
                    description = ''
                      The author of the scheme.
                    '';
                  };

                  variant = mkOption {
                    type = types.enum [
                      "light"
                      "dark"
                    ];
                    description = ''
                      The scheme shade system.
                    '';
                  };

                  palette = mkOption {
                    type = types.attrsOf types.str;
                    example = literalExpression ''{ base00 = "#1E1823"; }'';
                    description = ''
                      The scheme color palette as hex strings. Sixteen slots are upcast
                      to twenty-four; supply all twenty-four to control them yourself.
                    '';
                  };
                };
              };
              description = ''
                Provides a scheme written out in place of one from tinted-theming.
              '';
            };
          }
        );
        default = null;
        description = ''
          The source for the color scheme. Exactly one tag must be set.
        '';
      };

      accent = mkOption {
        type = types.str;
        default = "base0D";
        example = "#B478AE";
        description = ''
          The color consumers reach for when they need one that is not a background or a
          foreground. Either a palette slot name or a hex string.
        '';
      };

      interpolation.lightenWeight = mkOption {
        type = types.float;
        default = 0.2;
        description = ''
          How far the bright accents a base16 source lacks are lightened towards white.
        '';
      };

      overrides = {
        palette = colorRef;
        status = colorRef;
        ansi = colorRef;

        named = mkOption {
          type = types.attrsOf (types.attrsOf types.str);
          default = { };
          example = literalExpression ''{ background.dark = "base01"; }'';
          description = ''
            Colors replacing what the `named` view derived, keyed by color word and
            variant. A value either names a palette slot or is a hex string.
          '';
        };
      };

      scheme = mkOption {
        type = types.nullOr customTypes.scheme;
        readOnly = true;
        description = ''
          The scheme every other module reads. Every view is present for every scheme.
        '';
      };
    };

  config =
    let
      cfg = config.schemes;

      source =
        if cfg.source == null then
          null
        else if cfg.source ? tinted then
          libSchemes.generateScheme cfg.source.tinted.system cfg.source.tinted.slug
        else
          cfg.source.custom;

      scheme =
        if source == null then
          null
        else
          libSchemes.mkScheme {
            inherit source;
            inherit (cfg) accent overrides;
            inherit (cfg.interpolation) lightenWeight;
          };

    in
    {
      schemes.scheme = scheme;
    };
}
