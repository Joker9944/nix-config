{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    kanidm_1_8
    openldap
  ];

  # Kanidm configuration file
  # https://kanidm.github.io/kanidm/master/client_tools.html#kanidm-configuration
  xdg.configFile."kanidm".text = ''
    uri = "https://idm.vonarx.online"
  '';
}
