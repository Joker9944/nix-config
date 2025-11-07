{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
let
  hostModule = lib.path.append ./hosts osConfig.networking.hostName;
in
{
  inherit (osConfig) desktopEnvironment;

  imports = [ ./config ] ++ lib.optional (builtins.pathExists hostModule) hostModule;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  home.packages = with pkgs; [
    fastfetch
    imagemagick
    tree
    trash-cli

    meld

    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_CH
    papers

    joplin-desktop
    inkscape
    audacity

    vlc

    minio-client
  ];

  xdg = {
    autostart = {
      enable = true;

      entries = [ "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop" ];
    };

    mimeApps.enable = true;
  };

  programs = {
    bash.enable = true;

    vscode.enable = true;
    freelens.enable = true;

    telegram.enable = true;
    spotify.enable = true;
    discord = {
      enable = true;
      package = pkgs.vesktop;
    };

    git = {
      enable = true;
      userEmail = "9194199+Joker9944@users.noreply.github.com";
      userName = "Joker9944";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
      };
    };

    ssh.enable = true;

    _1password = {
      enable = true;

      sshIdentityAgentHosts = [ "*" ];

      sshAgentConfig = {
        ssh-keys = [
          {
            vault = "Private";
            item = "joker9944@" + osConfig.networking.hostName;
          }
        ];
      };

      autostart.enable = true;
    };

    home-manager.enable = true;
  };

  home.stateVersion = "24.05";
}
