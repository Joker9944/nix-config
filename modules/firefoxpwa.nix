{ config, lib, pkgs-unstable, ... }:

{
  config = lib.mkIf config.programs.firefox.enable {
    environment.systemPackages = with pkgs-unstable; [
      firefoxpwa
    ];

    programs.firefox = with pkgs-unstable; {
      nativeMessagingHosts.packages = [ firefoxpwa ];
    };
  };
}
