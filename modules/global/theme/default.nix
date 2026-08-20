{ flake, ... }@moduleArgs:
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
flake.lib.modules.mkDefaultModule
  {
    dir = ./.;

    args = moduleArgs // {
      mkThemeModule = flake.lib.modules.mkMixinModule {
        inherit config;
        prefix = [ "theme" ];
      };
    };
  }
  {
    # `nixosModules.scheme` and `homeModules.scheme` are the same class-agnostic file; this
    # module is the only importer in either tree, so `schemes` is declared exactly once.
    imports = [ inputs.nix-schemes.nixosModules.scheme ];

    options.custom.theme =
      let
        inherit (lib) mkOption types;

        # The module-arg `lib` carries `hm` only inside the home-manager tree; the flake
        # input exposes it to both. GTK's icon/cursor types are not exported the same way.
        inherit (inputs.home-manager.lib.hm.types) fontType;

        namedPackageType = types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = ''
                Name of the theme.
              '';
            };

            package = mkOption {
              type = types.package;
              description = ''
                Package providing the theme.
              '';
            };
          };
        };
      in
      {
        icons = mkOption {
          type = namedPackageType;
          description = ''
            Icon pack of the active theme.
          '';
        };

        cursor = mkOption {
          type = namedPackageType;
          description = ''
            Cursor theme of the active theme.
          '';
        };

        accent = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "#B478AE";
          description = ''
            Accent color of the active theme. When null the accent is derived from the scheme
            palette using `gtk.accent` as the selector.
          '';
        };

        gtk.accent = mkOption {
          type = types.enum [
            "blue"
            "teal"
            "green"
            "yellow"
            "orange"
            "red"
            "pink"
            "purple"
            "slate"
          ];
          default = "blue";
          description = ''
            The GTK accent color based on the GTK 4 accent system. Doubles as the palette
            selector when `accent` is null.
          '';
        };

        fonts = {
          interface = mkOption {
            type = fontType;
            description = ''
              Interface text font of the active theme.
            '';
          };

          terminal = mkOption {
            type = fontType;
            description = ''
              Terminal text font of the active theme.
            '';
          };

          document = mkOption {
            type = fontType;
            description = ''
              Document text font of the active theme.
            '';
          };

          monospace = mkOption {
            type = fontType;
            description = ''
              Monospace text font of the active theme.
            '';
          };

          emoji = mkOption {
            type = fontType;
            description = ''
              Emoji font of the the active theme.
            '';
          };
        };
      };

    config =
      let
        cfg = config.custom.theme;
      in
      {
        custom.theme.fonts = {
          interface = {
            name = "Inter";
            package = pkgs.inter;
            size = 10;
          };

          terminal = {
            name = "JetBrainsMono Nerd Font Mono";
            package = pkgs.nerd-fonts.jetbrains-mono;
            size = 10;
          };

          document = {
            name = "Lato";
            package = pkgs.lato;
            size = 12;
          };

          monospace = {
            name = "JetBrains Mono";
            package = pkgs.jetbrains-mono;
            size = 10;
          };

          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
            size = 10;
          };
        };

        # A scheme carries no accent of its own, so the theme adds one for its consumers.
        # Resolved against the in-progress scheme the transformer is handed, not
        # `config.schemes.scheme`, which this transformer is itself an input to.
        schemes.transformers = [
          (scheme: libSchemes: {
            accent =
              if cfg.accent != null then
                libSchemes.color.mkColor (libSchemes.color.fromHex cfg.accent)
              else
                (libSchemes.gtk.mkAccentsFromPalette scheme.palette).${cfg.gtk.accent};
          })
        ];
      };
  }
