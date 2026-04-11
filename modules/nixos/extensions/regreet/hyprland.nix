{ flake, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.programs.regreet.hyprland =
    let
      inherit (lib) mkPackageOption mkOption types;
    in
    {
      package = mkPackageOption pkgs "hyprland" { };

      settings = mkOption {
        type =
          with types;
          let
            valueType =
              nullOr (oneOf [
                bool
                int
                float
                str
                path
                (attrsOf valueType)
                (listOf valueType)
              ])
              // {
                description = "Hyprland configuration value";
              };
          in
          valueType;
        default = { };
        description = ''
          Hyprland configuration written in Nix. Entries with the same key
          should be written as lists. Variables' and colors' names should be
          quoted. See <https://wiki.hypr.land> for more examples.
        '';
      };
    };

  config =
    let
      cfg = config.programs.regreet;
      getHyprlandExe = lib.getExe' cfg.hyprland.package;
    in
    lib.mkIf (cfg.enable && cfg.compositor == "hyprland") {
      programs.regreet.hyprland.settings.exec-once = [
        "${lib.getExe cfg.package}; ${getHyprlandExe "hyprctl"} dispatch exit"
      ];

      services.greetd.settings.default_session.command =
        "${lib.getExe' pkgs.dbus "dbus-run-session"} ${getHyprlandExe "start-hyprland"} -- --config ${
          pkgs.writeTextFile {
            name = "greetd-hyprland.conf";
            text = flake.inputs.home-manager.lib.hm.generators.toHyprconf { attrs = cfg.hyprland.settings; };
          }
        }";
    };
}
