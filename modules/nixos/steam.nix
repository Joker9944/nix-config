{ lib, config, pkgs, ... }:

{

  config = lib.mkIf config.programs.steam.enable {

    programs = {
      steam = {
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = false;

        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };
      gamemode = {
        enable = true;
      };
      gamescope = {
        enable = false;
        capSysNice = true;
      };
    };

    environment = with pkgs; {
      systemPackages = [ mangohud ];
    };

    services.udev.dualsenseFix.enable = true;

  };

}
