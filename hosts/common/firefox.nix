{
  pkgs,
  lib,
  config,
  ...
}: {
  programs = {
    firefox = {
      enable = lib.mkDefault true;

      package = lib.mkDefault pkgs.librewolf;

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
      };
    };
  };

  # Redirect vanilla Firefox policies.json to a location librewolf recognizes
  environment.etc."firefox/policies/policies.json".target = lib.mkIf (config.programs.firefox.package == pkgs.librewolf) "librewolf/policies/policies.json";
}
