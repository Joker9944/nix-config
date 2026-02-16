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

    minio-client
  ];

  programs = {
    freelens.enable = true;
    saber.enable = true;

    scrcpy = {
      enable = true;
      args = [
        "--render-driver=opengl" # cSpell:ignore opengl
        "--video-codec=h265"
        "--keyboard=uhid"
      ];
    };

    git.settings.user = {
      email = "9194199+Joker9944@users.noreply.github.com";
      name = "Joker9944";
    };
  };

  home.stateVersion = "24.05";
}
