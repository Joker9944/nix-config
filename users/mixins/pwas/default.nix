{
  lib,
  pkgs,
  config,
  custom,
  ...
}:
custom.lib.mkDefaultModule { dir = ./.; } {
  config.programs.firefoxpwa.package = lib.mkDefault (
    pkgs.firefoxpwa.overrideAttrs (prev: {
      libs = "${config.programs.firefox.finalPackage.libs}:${prev.libs}";
    })
  );
}
