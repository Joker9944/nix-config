{
  lib,
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

  config.programs.firefoxpwa.package = lib.mkDefault (
    pkgs.firefoxpwa.overrideAttrs (prev: {
      libs = "${config.programs.firefox.finalPackage.libs}:${prev.libs}";
    })
  );
}
