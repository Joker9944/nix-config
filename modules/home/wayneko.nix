{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.programs.wayneko =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "wayneko";

      package = mkPackageOption pkgs "wayneko" { };

      systemd = {
        enable = mkEnableOption "wayneko systemd integration";

        target = mkOption {
          type = types.str;
          default = config.wayland.systemd.target;
          defaultText = literalExpression "config.wayland.systemd.target";
          example = "sway-session.target";
          description = ''
            The systemd target that will automatically start the wayneko service.

            When setting this value to `"sway-session.target"`,
            make sure to also enable {option}`wayland.windowManager.sway.systemd.enable`,
            otherwise the service may never be started.
          '';
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = "--background-colour 0xFFFFFF";
        };
      };
    };

  config =
    let
      cfg = config.programs.wayneko;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.wayneko = lib.mkIf cfg.systemd.enable {
        Unit = {
          Description = "wayneko";
          After = [ cfg.systemd.target ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };

        Service = {
          ExecStart = lib.concatStringsSep " " ([ (lib.getExe cfg.package) ] ++ cfg.systemd.extraArgs);
          Restart = "on-failure";
        };

        Install.WantedBy = [ cfg.systemd.target ];
      };
    };
}
