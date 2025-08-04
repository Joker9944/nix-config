{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.firefox-profile-switcher-connector;

  pkg = pkgs.firefox-profile-switcher-connector;
in {
  options.programs.firefox-profile-switcher-connector = with lib; {
    enable = mkEnableOption "the Firefox profile switcher connector needed for the extensions";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkg];

    programs = {
      firefox.nativeMessagingHosts = lib.mkIf config.programs.firefox.enable [pkg];
      librewolf.nativeMessagingHosts = lib.mkIf config.programs.librewolf.enable [pkg];
    };
  };
}
