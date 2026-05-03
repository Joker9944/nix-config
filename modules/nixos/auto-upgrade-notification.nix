_:
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.system.autoUpgrade.notify =
    let
      inherit (lib) mkEnableOption mkOption types;
    in
    {
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
        default = "nix-snowflake";
        description = ''
          Icon passed to `notify-send`.
        '';
      };

      name = mkOption {
        type = types.str;
        default = "NixOS";
        description = ''
          App name passed to `notify-send`.

          Supported vars:
           - instance
           - username
           - bus_route
        '';
      };

      summary = mkOption {
        type = types.str;
        default = "$instance failed";
        description = ''
          Summary passed to `notify-send`.

          Supported vars:
           - instance
           - username
           - bus_route
        '';
      };

      body = mkOption {
        type = types.lines;
        default = "Check the logs with \\\"journalctl -u nixos-upgrade.service\\\".";
        description = ''
          Body passed to `notify-send`.
        '';
      };
    };

  config =
    let
      cfg = config.system.autoUpgrade.notify;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ nixos-icons ];

      systemd.services = {
        # NixOS internal upgrade service
        # https://github.com/NixOS/nixpkgs/blob/1f08a4df998e21f4e8be8fb6fbf61d11a1a5076a/nixos/modules/system/boot/systemd.nix
        nixos-upgrade.onFailure = [ "nixos-upgrade-notify@%n.service" ];

        "nixos-upgrade-notify@" = {
          description = "NixOS Upgrade Notify";

          serviceConfig = {
            Type = "simple";
          };

          # Script adapted from
          # https://github.com/hackerb9/notify-send-all
          scriptArgs = "%i";
          script =
            let
              script = pkgs.writeShellApplication {
                name = "nixos-upgrade-notify_-start";

                text = ''
                  instance=$1
                  for username in $(who | cut -f1 -d" " | sort -u); do
                    bus_route="/run/user/$(id -u "$username")/bus"
                    if [[ -e "$bus_route" ]]; then
                      sudo -u "$username" \
                        DBUS_SESSION_BUS_ADDRESS="unix:path=$bus_route" \
                        -- \
                        notify-send --app-name="${cfg.name}" --urgency="${cfg.urgency}" --icon="${cfg.icon}" "${cfg.summary}" "${cfg.body}"
                    fi
                  done
                '';

                runtimeInputs = with pkgs; [
                  coreutils
                  sudo
                  libnotify
                ];
              };
            in
            lib.getExe script;
        };
      };
    };
}
