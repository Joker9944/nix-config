# https://docs.betterdiscord.app/discord/variables
flake:
{
  lib,
  config,
  ...
}:
let
  cfg = config.schemes.vesktop;
  libSchemes = flake.lib.libSchemes;
in
{
  options.schemes.vesktop =
    let
      inherit (lib) mkEnableOption mkOption;
      customTypes = libSchemes.types;

      anchors = import ./theme/anchors.nix cfg.scheme;

      mkColorOption =
        step: carries:
        mkOption {
          default = anchors.${step};
          type = customTypes.color;
          description = ''
            Color of the ${carries}.
          '';
        };
    in
    {
      enable = mkEnableOption "Vesktop theming based on a scheme";

      scheme = mkOption {
        type = customTypes.scheme;
        default = config.schemes.scheme;
        description = ''
          Color scheme used to customize Vesktop.
        '';
      };

      # Anchors on Discord's primitive ramps, not its semantic tokens. A token is a
      # reference into a ramp — often through alpha, as `--background-modifier-hover` is
      # `hsl(var(--primary-500-hsl)/0.3)` — so anchoring the ramp keeps every derived
      # state distinct, where overriding the token flattens them to one color. Every
      # remaining step is interpolated between these.
      colors = {
        "primary-130" = mkColorOption "primary-130" "brightest heading text";
        "primary-230" = mkColorOption "primary-230" "body text and hovered interactive elements";
        "primary-330" = mkColorOption "primary-330" "secondary text and resting interactive elements";
        "primary-400" = mkColorOption "primary-400" "channel icons";
        "primary-500" =
          mkColorOption "primary-500" "hover, active and selected backgrounds, applied at alpha";
        "primary-560" = mkColorOption "primary-560" "surface one step lighter than the main background";
        "primary-600" = mkColorOption "primary-600" "main background";
        "primary-700" = mkColorOption "primary-700" "sidebar background and activity cards";
        "primary-800" = mkColorOption "primary-800" "floating and overlay surfaces";

        "brand-500" = mkColorOption "brand-500" "brand surfaces and filled buttons";
        "red-400" = mkColorOption "red-400" "danger status and negative feedback";
        "green-430" = mkColorOption "green-430" "positive status and success feedback";
        "yellow-300" = mkColorOption "yellow-300" "warning foreground and mention backgrounds";
        "orange-300" = mkColorOption "orange-300" "orange ramp, unused by the dark theme";
        "blue-345" = mkColorOption "blue-345" "links";
        "teal-430" = mkColorOption "teal-430" "creator revenue buttons";

        "white-500" = mkColorOption "white-500" "active interactive elements, and borders at alpha";
        "black-500" = mkColorOption "black-500" "modal backdrop";
      };
    };

  config = lib.mkIf cfg.enable {
    programs.vesktop.vencord = {
      themes.scheme =
        let
          theme = import ./theme {
            inherit lib;
            inherit (cfg) colors;
          };

          # Nix renders a float with six decimals; Discord's own values carry one, and the
          # triple round-trips through 8-bit RGB anyway, so anything finer is noise.
          round = x: builtins.floor (x + 0.5);
          decimal =
            x:
            let
              tenths = round (x * 10);
            in
            "${toString (tenths / 10)}.${toString (tenths - (tenths / 10) * 10)}";

          # A bare `H S% L%` triple, because consumers compose it as
          # `hsl(var(--x-hsl)/<alpha>)`. The `--saturation-factor` wrapper is what carries
          # the client's saturation control through to the theme.
          hsl =
            color:
            let
              inherit (libSchemes.color.toHsl color) h s l;
            in
            "${toString (round h)} calc(var(--saturation-factor, 1)*${decimal (s * 100)}%) ${decimal (l * 100)}%";

          declaration =
            name: color: "  --${name}-hsl: ${hsl color};\n  --${name}: hsl(var(--${name}-hsl)/1);";
        in
        ''
          /**
           * @name ${cfg.scheme.meta.name}
           * @author ${cfg.scheme.meta.author}
           * @description Discord's primitive color ramps, generated from a nix-schemes scheme.
           * @version 1.0.0
           **/

          :root {
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList declaration theme)}
          }
        '';

      settings.enabledThemes = lib.mkDefault [ "scheme.css" ];
    };
  };
}
