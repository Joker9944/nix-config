# Adapted from https://github.com/lucasew/nixcfg/blob/36241aa6fa5935c861f3d91f7e973e7dbf4ed58d/nix/pkgs/wrapWine.nix
{ lib }:
{ pkgs }:
{
  prefixName,
  wine ? pkgs.wine,
  winetricksArgs ? [ ],
  setupScript ? "",
  firstRunScript ? "",
  chdir ? null,
  prefixCommands ? [ ],
  wineFlags ? [ ],
}:
let
  path = lib.makeBinPath [
    wine
    pkgs.cabextract
  ];

  bin = {
    wine = lib.getExe wine;
    wineboot = lib.getExe' wine "wineboot";
    wineserver = lib.getExe' wine "wineserver";
    winetricks = lib.getExe pkgs.winetricks;
  };

  wineArch = if (lib.hasSuffix "64" bin.wine) then "win64" else "win32";

  tricksCommand =
    if (lib.length winetricksArgs) > 0 then
      "${bin.winetricks} ${lib.concatStringsSep " " winetricksArgs}"
    else
      "# no winetricks set";

  prefixes =
    if (lib.length prefixCommands) > 0 then "${lib.concatStringsSep " " prefixCommands} " else "";

  flags = if (lib.length wineFlags) > 0 then " ${lib.concatStringsSep " " wineFlags}" else "";

  script = pkgs.writeShellScriptBin prefixName ''
    set -eu -o pipefail

    export PATH=$PATH:${path}

    export WINEARCH=${wineArch}
    export WINEPREFIX="$HOME/.wine/${prefixName}"

    ${setupScript}
    if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
    then
      ${bin.wineboot} --update
      ${bin.wineserver} --wait
      ${tricksCommand}
      ${firstRunScript}
    fi
    ${if chdir != null then "cd \"${chdir}\"" else "# don't change directory"}

    exec ${prefixes}${bin.wine}${flags} "$@"
    ${bin.wineserver} --wait
  '';
in
script
