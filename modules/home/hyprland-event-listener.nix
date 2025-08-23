{
  lib,
  config,
  pkgs,
  utility,
  ...
}:
let
  cfg = config.services.hyprland.eventListener;

  mkScript = pkgs.writeShellScript "hyprland-event-listener.sh";

  script =
    let
      bin.socat = "${cfg.socat.package}/bin/socat";

      functions = lib.concatLines (
        lib.map (entry: ''
          ${entry.name}() {
          ${utility.custom.indentLines 2 (lib.removeSuffix "\n" entry.value.body)}
          }
        '') (lib.attrsToList cfg.listener)
      );

      handleCases = lib.concatLines (
        lib.map (entry: "${entry.value.event}) ${entry.name} \"\$2\" ;;") (lib.attrsToList cfg.listener)
      );
    in
    # cSpell:words hypr
    ''
      set -e

      ${functions}
      handle() {
        case "$1" in
      ${utility.custom.indentLines 4 (lib.removeSuffix "\n" handleCases)}
        esac
      }

      ${bin.socat} -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock |
      while read -r line; do
        event="''${line%%>>*}"
        data="''${line#*>>}"
        handle "$event" "$data"
      done
    '';
in
{
  options.services.hyprland.eventListener = with lib; {
    enable = mkEnableOption "Hyprland event listener service";

    socat.package = mkPackageOption pkgs "socat" { };

    systemd = {
      enable = mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to enable Hyprland event listener systemd service.";
      };

      target = mkOption {
        type = types.str;
        default = config.wayland.systemd.target;
        defaultText = lib.literalExpression "config.wayland.systemd.target";
        example = "hyprland-session.target";
        description = ''
          The systemd target that will automatically start the Hyprland event listener.
        '';
      };
    };

    listener =
      let
        listenerSubmodule = types.submodule (_: {
          options = {
            event = mkOption {
              type = types.str;
              default = null;
              description = ''
                event type
              '';
            };

            body = mkOption {
              type = types.lines;
              default = null;
              description = ''
                function body
              '';
            };
          };
        });
      in
      mkOption {
        type = types.attrsOf listenerSubmodule;
        default = { };
        example = { };
        description = ''
          TODO finish this module
        '';
      };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.socat.package ];

    systemd.user.services.hyprland-event-listener = {
      Unit = {
        Description = "Hyprland event listener";
        After = [ cfg.systemd.target ];
      };

      Service = {
        ExecStart = toString (mkScript script);
        Restart = "on-failure";
      };

      Install.WantedBy = [ cfg.systemd.target ];
    };
  };
}
