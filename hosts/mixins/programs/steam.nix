{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  custom,
  ...
}:
{
  options.mixins.programs.steam =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "1Password config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.steam;
    in
    lib.mkIf cfg.enable {
      custom.nixpkgsCompat.allowUnfreePackages = [
        "steam"
        "steam-unwrapped"
      ];

      programs = {
        steam = {
          enable = true;

          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;

          extraCompatPackages = with pkgs-unstable; [ proton-ge-bin ];
          extraPackages = with pkgs; [ libstrangle ];

          protontricks.enable = true;
        };

        gamescope = {
          enable = true;
          args =
            let
              _resolution = lib.splitString "x" custom.config.resolution;
            in
            [
              "--output-width=${lib.elemAt _resolution 0}"
              "--output-height=${lib.elemAt _resolution 1}"
              "--rt"
              "--expose-wayland"
              "--adaptive-sync"
            ];
          capSysNice = false;
        };

        gamemode = {
          enable = true;
          settings.general.renice = 20;
        };
      };

      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;

        # WORKAROUND moves realtime tasks to the root cgroup to move them to the ananicy-cpp controlled cgroups.
        # This messes with polkit, for examples takes hyprland out of the session slice cgroup which breaks various things.
        settings.cgroup_realtime_workaround = lib.mkForce false;
      };

      environment = with pkgs; {
        systemPackages = [
          mangohud
          pkgs-unstable.r2modman
        ];
      };

      # Support for 32-bit games
      hardware.graphics.enable32Bit = true;

      services.udev.dualsenseFix = true;
    };
}
