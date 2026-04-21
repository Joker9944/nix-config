{ lib, config, ... }:
{
  options =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      programs.wallust.templates.dunst = {
        enable = mkEnableOption "dunst wallust config";

        template = mkOption {
          # Taken from home-manager
          # https://github.com/nix-community/home-manager/blob/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe/modules/services/dunst.nix#L101
          type = with types; attrsOf (attrsOf (either str (either bool (either int (listOf str)))));

          default = literalExpression ''
            {
              global = {
                frame_color = "{{color4}}";
                highlight = "{{color5}}";
                separator_color = "{{foreground}}";
              };

              urgency_low = {
                background = "{{background | darken(0.1)}}ee";
                foreground = "{{foreground}}";
                frame_color = "{{color4}}";
              };

              urgency_normal = {
                background = "{{background | darken(0.1)}}80";
                foreground = "{{foreground}}";
                frame_color = "{{color6}}";
              };

              urgency_critical = {
                background = "{{background | darken(0.1)}}ee";
                foreground = "{{foreground}}";
                frame_color = "{{color9}}";
              };
            }
          '';

          description = ''
            Template for config snipped which will be added as a dunst config override.
          '';
        };
      };
    };

  config =
    let
      cfg = config.programs.wallust;

      # Taken from home-manager
      # https://github.com/nix-community/home-manager/blob/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe/modules/services/dunst.nix#L19-L32
      toDunstIni = lib.generators.toINI {
        mkKeyValue =
          key: value:
          let
            value' =
              if lib.isBool value then
                (lib.hm.booleans.yesNo value)
              else if lib.isString value then
                ''"${value}"''
              else
                toString value;
          in
          "${key}=${value'}";
      };
    in
    lib.mkIf (cfg.enable && cfg.templates.dunst.enable) {
      xdg.configFile."wallust/templates/dunst.conf".text = toDunstIni cfg.templates.dunst.template;

      programs.wallust.settings.templates.dunst = {
        template = "dunst.conf";
        target = "~/.config/dunst/dunstrc.d/wallust.conf"; # cSpell:ignore dunstrc.d
      };

      systemd.user.services.dunst.Unit.X-Reload-Triggers = [ "~/.config/dunst/dunstrc.d/wallust.conf" ];
    };
}
