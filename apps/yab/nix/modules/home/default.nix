flake:
{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.programs.yab =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "yab";

      package = mkOption {
        type = types.package;
        default = flake.packages.${pkgs.stdenv.hostPlatform.system}.yab;
        defaultText = literalExpression "inputs.yab.packages.\${pkgs.stdenv.hostPlatform.system}.yab";
        description = "The yab package to use.";
      };

      systemd = {
        enable = mkEnableOption "yab systemd integration";

        target = mkOption {
          type = types.str;
          default = config.wayland.systemd.target;
          defaultText = literalExpression "config.wayland.systemd.target";
          example = "sway-session.target";
          description = ''
            The systemd target that will automatically start the Waybar service.

            When setting this value to `"sway-session.target"`,
            make sure to also enable {option}`wayland.windowManager.sway.systemd.enable`,
            otherwise the service may never be started.
          '';
        };
      };
    };

  config =
    let
      cfg = config.programs.yab;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.yab = lib.mkIf cfg.systemd.enable {
        Unit = {
          Description = "yab - yet another bar";
          PartOf = [
            cfg.systemd.target
            "tray.target"
          ];
          After = [ cfg.systemd.target ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
          X-Reload-Triggers =
            lib.optional config.gtk.gtk4.enable
              config.xdg.configFile."gtk-4.0/gtk.css".source;
        };

        Service = {
          ExecStart = lib.getExe cfg.package;
          Restart = "on-failure";
          KillMode = "mixed";
        };

        Install.WantedBy = [
          cfg.systemd.target
          "tray.target"
        ];
      };
    };
}
