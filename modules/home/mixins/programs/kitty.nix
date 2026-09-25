{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "kitty" {
  programs.kitty = {
    enable = true;

    enableGitIntegration = config.programs.git.enable;

    settings = {
      enabled_layouts = "splits:split_axis=auto,stack";
      allow_remote_control = "socket-only";
      listen_on = "unix:@kitty";
    };
  };

  xdg = {
    terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };

    mimeApps.custom.apps.default = [
      "${config.programs.kitty.package}/share/applications/kitty-open.desktop"
    ];
  };
}
