# Adapted from https://github.com/lucasew/nixcfg/blob/36241aa6fa5935c861f3d91f7e973e7dbf4ed58d/nix/pkgs/wrapWine.nix
{ lib }:
{ pkgs }:
{
  prefixName,
  wine ? pkgs.wine,
  x64 ? false,
  winetricksArgs ? [ ],
  setupScript ? "",
  firstRunScript ? "",
  chdir ? null,
  prefixCommands ? [ ],
  wineFlags ? [ ],
}:
let
  umu = pkgs.umu-launcher.overrideAttrs {
    extraLibraries = with pkgs; [
      libpulseaudio # cSpell:words libpulseaudio
      vulkan-loader
      freetype # cSpell:words freetype
      xorg.libXcomposite # cSpell:words libXcomposite
      xorg.libXrandr # cSpell:words libXrandr
      xorg.libXfixes # cSpell:words libXfixes
      xorg.libXcursor
      xorg.libXi
    ];
  };

  bin = {
    wine = lib.getExe wine;
    wineboot = lib.getExe' wine "wineboot";
    wineserver = lib.getExe' wine "wineserver";
    winetricks = lib.getExe pkgs.winetricks;
    umu-run = lib.getExe umu;
  };

  wineArch = if x64 then "win64" else "win32";

  tricksCommand =
    if (lib.length winetricksArgs) > 0 then
      "${bin.umu-run} winetricks ${lib.concatStringsSep " " winetricksArgs}"
    else
      "# no winetricks set";

  prefixes =
    if (lib.length prefixCommands) > 0 then "${lib.concatStringsSep " " prefixCommands} " else "";

  flags = if (lib.length wineFlags) > 0 then " ${lib.concatStringsSep " " wineFlags}" else "";

  script = pkgs.writeShellScriptBin prefixName ''
    set -eu -o pipefail

    export WINEARCH=${wineArch}
    export WINEPREFIX="$HOME/.wine/${prefixName}"

    ${setupScript}
    if [ ! -d "$WINEPREFIX" ] # if the prefix does not exist
    then
      ${tricksCommand}
      ${firstRunScript}
    fi
    ${if chdir != null then "cd \"${chdir}\"" else "# don't change directory"}

    exec ${prefixes}${bin.umu-run}${flags} "$@"
  '';
in
script
