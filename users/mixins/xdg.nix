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

      extraConfig = {
        PROJECTS = "${config.home.homeDirectory}/Workspace";
        SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
