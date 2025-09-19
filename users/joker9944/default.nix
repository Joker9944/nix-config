{
  lib,
  pkgs,
  config,
  osConfig,
  utility,
  ...
}:
let
  hostModule = lib.path.append ./. "hosts/${osConfig.networking.hostName}.nix";
in
{
  inherit (osConfig) desktopEnvironment;

  # TODO auto import
  imports =
    (utility.custom.ls.lookup {
      dir = ./config;
    })
    ++ lib.optional (builtins.pathExists hostModule) hostModule; # Import matching host modules

  home.packages = with pkgs; [
    fastfetch
    imagemagick
    tree
    trash-cli

    meld
    lens

    libreoffice
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_CH

    joplin-desktop
    xournalpp
    inkscape
    audacity

    vlc

    nextcloud-client
    minio-client
  ];

  xdg.autostart = {
    enable = true;

    entries = [ "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop" ];
  };

  programs = {
    # TEST
    faf = {
      enable = true;
      proton.path = "${config.programs.faf.steam.library.path}/steamapps/common/Proton 10.0";
      steam = {
        enable = false;
        library.path = "/mnt/games/SteamLibrary";
      };
    };

    bash.enable = true;

    vscode.enable = true;

    telegram.enable = true;
    spotify.enable = true;
    discord.enable = true;

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
