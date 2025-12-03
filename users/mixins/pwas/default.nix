{
  pkgs,
  config,
  custom,
  ...
}:
{
  imports = custom.lib.ls {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.programs.firefoxpwa.package = pkgs.firefoxpwa.overrideAttrs {
    inherit (config.programs.firefox.package) libs;
  };
}
