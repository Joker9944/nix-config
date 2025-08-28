{
  lib,
  config,
  osConfig,
  utility,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland;
in
utility.custom.mkHyprlandModule config {
  imports = utility.custom.ls.lookup {
    dir = ./.;
    exclude = [ ./default.nix ];
  };

  config.wayland = {
    systemd.target = lib.mkIf cfg.systemd.enable "hyprland-session.target";

    windowManager.hyprland = {
      inherit (osConfig.programs.hyprland) package portalPackage;
      enable = true;

      systemd.enable = !osConfig.programs.hyprland.withUWSM;

      # WORKAROUND This is a hack to workaround a hack in NixOS
      # See here: https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988
      # Remove when https://github.com/NixOS/nixpkgs/blob/fafef5049e2a7bcc36802e1ce72cd2f51d386388/nixos/modules/services/x11/display-managers/default.nix#L28-L50 ever gets fixed
      settings.env = [ "XDG_CURRENT_DESKTOP, Hyprland" ];
    };
  };
}
