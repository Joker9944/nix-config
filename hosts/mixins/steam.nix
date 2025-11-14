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

          extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];

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
          settings.general.renice = 10;
        };
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
