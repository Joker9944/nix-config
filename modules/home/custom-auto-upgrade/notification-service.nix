{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.customAutoUpgrade.notify;
in
{
  options.services.customAutoUpgrade.notify = with lib; {
    enable = mkEnableOption "NixOS Upgrade Service failure notification";

    urgency = mkOption {
      type = types.enum [
        "low"
        "normal"
        "critical"
      ];
      default = "normal";
      description = ''
        Urgency level passed to `notify-send`.
      '';
    };

    icon = mkOption {
      type = types.str;
      default = "${pkgs.nixos-icons}/share/icons/hicolor/24x24/apps/nix-snowflake.png";
      description = ''
        Icon filepath passed to `notify-send`.
      '';
    };

    name = mkOption {
      type = types.str;
      default = "Home Manager";
      description = ''
        App name passed to `notify-send`.

        Supported vars:
         - instance
      '';
    };

    summary = mkOption {
      type = types.str;
      default = "$instance failed";
      description = ''
        Summary passed to `notify-send`.

        Supported vars:
         - instance
      '';
    };

    body = mkOption {
      type = types.lines;
      default = ''
        Check the logs with \"journalctl --user-unit home-manager-upgrade.service\".
      '';
      description = ''
        Body passed to `notify-send`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];

    systemd.user.services = {
      home-manager-upgrade.Unit.OnFailure = "home-manager-upgrade-notify@%n.service";

      "home-manager-upgrade-notify@" = {
        Unit = {
          Description = "Home Manager Upgrade Notify";
        };

        Service = {
          Type = "simple";

          ExecStart =
            let
              bin = {
                notify-send = "${pkgs.libnotify}/bin/notify-send";
              };
            in
            toString (
              pkgs.writeShellScript "home-manager-upgrade-notify_-start" ''
                set -e

                instance=$1
                ${bin.notify-send} --app-name="${cfg.name}" --urgency=${cfg.urgency} --icon="${cfg.icon}" "${cfg.summary}" "${cfg.body}"
              ''
            )
            + " %i";
        };
      };
    };
  };
}
