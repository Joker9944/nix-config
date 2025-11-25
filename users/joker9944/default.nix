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
  imports = [ ./config ] ++ lib.optional (builtins.pathExists hostModule) hostModule;

  mixins = { inherit (osConfig.mixins) desktopEnvironment; };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  home.packages = with pkgs; [
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
    autostart.enable = true;
    mimeApps.enable = true;
  };

  programs = {
    freelens.enable = true;

    git = {
      userEmail = "9194199+Joker9944@users.noreply.github.com";
      userName = "Joker9944";
    };
  };

  home = {
    enableNixpkgsReleaseCheck = false;
    stateVersion = "24.05";
  };
}
