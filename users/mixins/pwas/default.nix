{
  pkgs,
  config,
  utility,
  ...
}:
{
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.programs.firefoxpwa.package = pkgs.firefoxpwa.overrideAttrs (
    final: prev: {
      inherit (config.programs.firefox.package) libs;
    }
  );
}
