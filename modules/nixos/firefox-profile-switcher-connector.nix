{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.firefox.enable {
    environment.systemPackages = with pkgs; [
      firefox-profile-switcher-connector
    ];

    programs.firefox = with pkgs; {
      nativeMessagingHosts.packages = [ firefox-profile-switcher-connector ];
    };
  };
}
