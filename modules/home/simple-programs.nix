{
  lib,
  pkgs,
  config,
  ...
}:
let
  programs = [
    {
      name = "discord";
    }
    {
      name = "gnome-text-editor";
    }
    {
      name = "loupe";
    }
    {
      name = "nextcloud-client";
    }
    {
      name = "papers";
    }
    {
      name = "spotify";
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
      name = "wxmaxima";
    }
    {
      name = "xournalpp";
    }
  ];
in
{
  options.programs = lib.pipe programs [
    (lib.map (
      {
        name,
        package ? name,
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
        name,
        ...
      }:
      let
        cfg = config.programs.${name};
      in
      lib.optional cfg.enable cfg.package
    ))
    lib.flatten
  ];
}
