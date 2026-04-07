{ lib, config, ... }:
{
  options.mixins.localization =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "localization config mixin";
    };

  config =
    let
      cfg = config.mixins.localization;

      locale = {
        us = "us";
        de = "de";
        en_US = "en_US.UTF-8";
        de_CH = "de_CH.UTF-8";
      };
    in
    lib.mkIf cfg.enable {
      time.timeZone = "Europe/Zurich";

      i18n = with locale; {
        defaultLocale = en_US;
        extraLocaleSettings = {
          LC_ADDRESS = de_CH;
          LC_IDENTIFICATION = de_CH;
          LC_MONETARY = de_CH;
          LC_MEASUREMENT = de_CH;
          LC_NAME = de_CH;
          LC_NUMERIC = de_CH;
          LC_PAPER = de_CH;
          LC_TELEPHONE = de_CH;
          LC_TIME = de_CH;
        };
      };
    };
}
