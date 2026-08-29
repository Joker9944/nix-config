{ mkMixinModule, ... }:
{ config, ... }:
mkMixinModule "xdg" {
  xdg = {
    autostart.enable = true;
    mimeApps.enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;

      projects = "${config.home.homeDirectory}/Workspace";

      extraConfig.SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };
}
