{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}: {
  config = lib.mkIf config.programs.steam.enable {
    programs = {
      steam = {
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = false;

        extraCompatPackages = with pkgs; [pkgs-unstable.proton-ge-bin];
      };
      gamemode = {
        enable = true;
      };
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };

    environment = with pkgs; {
      systemPackages = [mangohud pkgs-unstable.r2modman];
    };

    # Support for 32-bit games
    hardware.graphics.enable32Bit = true;

    services.udev.dualsenseFix = true;
  };
}
