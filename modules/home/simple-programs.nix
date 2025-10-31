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
      name = "nextcloud";
      package = "nextcloud-client";
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
  mkSimpleProgramModule =
    {
      name,
      package ? name,
    }:
    {
      options.programs.${name} =
        let
          inherit (lib) mkEnableOption mkPackageOption;
        in
        {
          enable = mkEnableOption name;
          package = mkPackageOption pkgs package { };
        };

      config =
        let
          cfg = config.programs.${name};
        in
        lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];
        };
    };
in
lib.foldl (acc: module: lib.recursiveUpdate acc module) { } (lib.map mkSimpleProgramModule programs)
