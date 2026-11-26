_:
{ lib, config, ... }:
let
  cfg = config.home.shellAbbrs;
in
{
  options.home.shellAbbrs = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      untar = "tar -xvf";
    };
    description = ''
      Abbreviations for fish, aliases for every other shell.
    '';
  };

  config.programs = {
    bash.shellAliases = cfg;
    zsh.shellAliases = cfg;
    nushell.shellAliases = cfg;
    fish.shellAbbrs = cfg;
  };
}
