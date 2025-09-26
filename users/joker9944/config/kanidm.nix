{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    kanidm_1_7
    openldap
  ];

  # Kanidm configuration file
  # https://kanidm.github.io/kanidm/master/client_tools.html#kanidm-configuration
  xdg.configFile."kanidm".text = ''
    uri = "https://idm.vonarx.online"
  '';
}
