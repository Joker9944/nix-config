_:
{ lib, config, ... }:
{
  config = lib.mkIf config.programs.navi.enable {
    xdg.dataFile."navi/cheats/joker9944".source = ./files;
  };
}
