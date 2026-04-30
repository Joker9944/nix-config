{ flake, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.yas =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "yas";

      package = mkOption {
        type = types.package;
        default = flake.packages.${pkgs.stdenv.hostPlatform.system}.yas;
        defaultText = literalExpression "inputs.yas.packages.\${pkgs.stdenv.hostPlatform.system}.yas";
        description = "The yas package to use.";
      };

      systemd = {
        enable = mkEnableOption "yas systemd integration";

        target = mkOption {
          type = types.str;
          default = config.wayland.systemd.target;
          defaultText = literalExpression "config.wayland.systemd.target";
          example = "sway-session.target";
          description = ''
            The systemd target that will automatically start the yas service.

            When setting this value to `"sway-session.target"`,
            make sure to also enable {option}`wayland.windowManager.sway.systemd.enable`,
            otherwise the service may never be started.
          '';
        };
      };

      config = mkOption {
        inherit (jsonFormat) type;
        default = { };
        description = ''
          The yas config;
        '';
      };
    };

  config =
    let
      cfg = config.programs.yas;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      xdg.configFile."yas/config.json" = lib.mkIf (cfg.config != { }) {
        source = jsonFormat.generate "yas-config.json" cfg.config;
      };

      systemd.user.services.yas = lib.mkIf cfg.systemd.enable {
        Unit = {
          Description = "yas - yet another shell";
          PartOf = [
            cfg.systemd.target
            "tray.target"
          ];
          After = [ cfg.systemd.target ];
          ConditionEnvironment = "WAYLAND_DISPLAY";
          X-Reload-Triggers =
            (lib.optional config.gtk.gtk4.enable config.xdg.configFile."gtk-4.0/gtk.css".source)
            ++ (lib.optional (cfg.config != { }) config.xdg.configFile."yas/config.json".source);
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
