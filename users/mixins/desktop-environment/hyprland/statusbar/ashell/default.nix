{
  lib,
  config,
  pkgs-hyprland,
  ...
}:
{
  config.programs.ashell = lib.mkIf config.programs.ashell.enable {
    package = pkgs-hyprland.ashell;

    systemd.enable = true;

    settings = {
      position = "Top";

      modules = {
        left = [
          "Workspaces"
        ];

        center = [
          "Clock"
        ];

        right = [
          "SystemInfo"
          [
            "Privacy"
            "Settings"
          ]
        ];
      };

      system_info = {
        indicators = [
          "Cpu"
          "Memory"
          { Disk = "/"; }
          "DownloadSpeed"
          "UploadSpeed"
        ];
      };

      settings = {
        shutdown_cmd = "poweroff";
        suspend_cmd = "systemctl suspend";
        hibernate_cmd = "systemctl hibernate";
        reboot_cmd = "reboot";
        logout_cmd = "loginctl kill-user $(whoami)";
      };
    };
  };
}
