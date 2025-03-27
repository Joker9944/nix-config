{pkgs, ...}: {
  home.packages = with pkgs; [
    kanidm_1_5
    openldap
  ];

  # Kanidm configuration file
  # https://kanidm.github.io/kanidm/master/client_tools.html#kanidm-configuration
  xdg.configFile."kanidm".text = ''
    uri = "https://idm.vonarx.online"
  '';
}
