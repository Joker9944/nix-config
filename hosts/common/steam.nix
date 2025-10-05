{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  custom,
  ...
}:
{
  config = lib.mkIf config.programs.steam.enable {
    custom.nixpkgsCompat.allowUnfreePackages = [
      "steam"
      "steam-unwrapped"
    ];

    programs = {
      steam = {
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;

        extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];
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
