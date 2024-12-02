{ pkgs, ...}:

{
  home.packages = with pkgs; [
    kanidm
    openldap
  ];

  # Kanidm configuration file
  # https://kanidm.github.io/kanidm/master/client_tools.html#kanidm-configuration
  home.file.".config/kanidm".text = ''
    uri = "https://idm.vonarx.online"
  '';
}
