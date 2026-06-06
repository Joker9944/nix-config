{
  lib,
  config,
  custom,
  ...
}:
{
  options.mixins.programs.telegram =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "telegram config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.telegram;
      inherit (config.programs.telegram) package;
      workspace = "telegram";
    in
    lib.mkIf cfg.enable {
      programs.telegram.enable = true;

      xdg.autostart.entries = [
        "${package}/share/applications/org.telegram.desktop.desktop"
      ];

      wayland.windowManager.hyprland.settings = {
        bind =
          let
            inherit (config.mixins.desktopEnvironment.hyprland.binds) mods;
            inherit (custom.lib) mkLuaCall;
            inherit (lib.generators) mkLuaInline;
          in
          [
            (mkLuaCall [
              "${mods.app} + T"
              (mkLuaInline "hl.dsp.workspace.toggle_special(\"${workspace}\")")
            ])
          ];

        workspace_rule = [
          {
            workspace = "special:${workspace}";
            on_created_empty = "Telegram";
          }
        ];

        window_rule = [
          {
            name = "telegram";
            match.class = "org.telegram.desktop";
            workspace = "special:${workspace} silent";
          }
          {
            name = "telegram-media";
            match = {
              class = "org.telegram.desktop";
              title = "Media viewer";
            };
            content = "photo";
            float = true;
          }
        ];
      };
    };
}
