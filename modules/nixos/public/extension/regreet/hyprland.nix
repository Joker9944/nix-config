_:
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

      execOnce = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Shell commands to run once on greeter startup. Rendered into a single
          `hl.on("hyprland.start", …)` hook as `hl.exec_cmd` calls.
        '';
      };

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
          Hyprland configuration written in Nix, rendered as Lua. Each top-level
          entry becomes an `hl.<name>(…)` call (e.g. `config`, `window_rule`);
          list values emit one call per element. See <https://wiki.hypr.land>.
        '';
      };
    };

  config =
    let
      cfg = config.programs.regreet;
      getHyprlandExe = lib.getExe' cfg.hyprland.package;

      # UPGRADE(26.11): drop this local renderer; home-manager unstable exposes the
      # Hyprland Lua generator as a lib function.
      toLua = lib.generators.toLua { };
      renderArgs =
        v: if lib.isAttrs v && v ? _args then lib.concatMapStringsSep ", " toLua v._args else toLua v;
      toHlLua =
        settings:
        lib.concatStrings (
          lib.mapAttrsToList (
            name: value:
            let
              items = if builtins.isList value then value else [ value ];
            in
            lib.concatMapStrings (x: "hl.${name}(${renderArgs x})\n") items
          ) settings
        );
    in
    lib.mkIf (cfg.enable && cfg.compositor == "hyprland") {
      programs.regreet.hyprland.execOnce = [
        "${lib.getExe cfg.package}; ${getHyprlandExe "hyprctl"} dispatch exit"
      ];

      services.greetd.settings.default_session.command =
        let
          hyprlandConfig = pkgs.writeTextFile {
            name = "greetd-hyprland.lua";
            text = toHlLua cfg.hyprland.settings + ''
              hl.on("hyprland.start", (function()
              ${lib.concatMapStrings (c: "  hl.exec_cmd(${toLua c})\n") cfg.hyprland.execOnce}end))
            '';
          };
        in
        "${lib.getExe' pkgs.dbus "dbus-run-session"} ${getHyprlandExe "start-hyprland"} -- --config ${hyprlandConfig}";
    };
}
