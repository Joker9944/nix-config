{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  config = lib.mkIf config.programs.steam.enable {
    programs = {
      steam = {
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;

        extraCompatPackages = [ pkgs-unstable.proton-ge-bin ];
      };

      gamescope.enable = true;

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
