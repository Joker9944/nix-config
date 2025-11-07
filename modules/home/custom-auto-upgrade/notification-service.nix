{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.home-manager.autoUpgrade.notify = with lib; {
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

  config =
    let
      cfg = config.services.home-manager.autoUpgrade.notify;
    in
    lib.mkIf cfg.enable {
      home.packages = [ pkgs.libnotify ];

      systemd.user.services =
        let
          serviceName = "home-manager-auto-upgrade";
        in
        {
          ${serviceName}.Unit.OnFailure = "${serviceName}-notify@%n.service";

          "${serviceName}-notify@" = {
            Unit = {
              Description = "Home Manager Upgrade Notify";
            };

            Service = {
              Type = "simple";

              Environment =
                let
                  path = with pkgs; lib.makeBinPath [ libnotify ];
                in
                "\"PATH=$PATH:${path}\"";

              ExecStart =
                let
                  scriptPath = pkgs.writeShellScript "${serviceName}-notify_-start" ''
                    instance=$1
                    notify-send --app-name="${cfg.name}" --urgency=${cfg.urgency} --icon="${cfg.icon}" "${cfg.summary}" "${cfg.body}"
                  '';
                in
                "${scriptPath} %i";
            };
          };
        };
    };
}
