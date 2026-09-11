_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  programs = [
    {
      package = "gnome-text-editor";
    }
    {
      package = "loupe";
    }
    {
      package = "nextcloud-client";
    }
    {
      package = "papers";
    }
    {
      package = "spotify";
    }
    {
      name = "teamspeak";
      package = "teamspeak3";
    }
    {
      name = "telegram";
      package = "telegram-desktop";
    }
    {
      package = "wxmaxima";
    }
    {
      package = "xournalpp";
    }
    {
      name = "freelens";
      package = "freelens-bin";
    }
    {
      name = "zoom";
      package = "zoom-us";
    }
    {
      package = "saber";
    }
    {
      package = "zap";
    }
    {
      package = "systemctl-tui";
    }
    {
      package = "grimblast";
    }
    {
      name = "signal";
      package = "signal-desktop";
    }
    {
      package = "opencloud-desktop";
    }
  ];
in
{
  options.programs = lib.pipe programs [
    (lib.map (
      {
        name ? package,
        package,
      }:
      {
        inherit name;
        value =
          let
            inherit (lib) mkEnableOption mkPackageOption;
          in
          {
            enable = mkEnableOption name;
            package = mkPackageOption pkgs package { };
          };
      }
    ))
    lib.listToAttrs
  ];

  config.home.packages = lib.pipe programs [
    (lib.map (
      {
        name ? package,
        package,
      }:
      let
        cfg = config.programs.${name};
      in
      lib.optional cfg.enable cfg.package
    ))
    lib.flatten
  ];
}
