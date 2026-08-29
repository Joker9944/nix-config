_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.xdg.mimeApps;
in
{
  options.xdg.mimeApps.custom.apps.default =
    let
      inherit (lib) mkOption types literalExpression;
    in
    mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression ''
        [ "''${config.programs.papers.package}/share/applications/org.gnome.Papers.desktop" ]
      '';
      description = ''
        Paths of desktop files whose mime types should be set as defaults. Earlier entries
        win over later ones for a type both declare.
      '';
    };

  config.xdg.mimeApps = lib.mkIf cfg.enable {
    # One directory per entry: home-manager reads every `.desktop` a package holds, and
    # a package usually holds more than the one entry meant to claim the type.
    defaultApplicationPackages = lib.map (
      desktopFile:
      let
        name = builtins.baseNameOf desktopFile;
      in
      pkgs.runCommandLocal "mimeapps-${name}" { } ''
        install -Dm444 "${desktopFile}" "$out/share/applications/${name}"
      ''
    ) cfg.custom.apps.default;
  };
}
