# Launcher for Supreme Commander: Forged Alliance under umu/Proton, invoked by
# the FAF client via its `executableDecorator` preference with the game
# executable as the argument.
#
# Static launch knowledge (appid, umu env, DXVK config) is baked here; the
# per-host bits (Proton choice, prefix commands, steam integration) are
# override arguments set from the home module.
{
  lib,
  writeShellApplication,
  writeText,
  coreutils,
  umu-launcher,
  steam-run-free,
  proton-ge-bin,

  prefixName ? "faf",
  # Client state dir; the game runs from `${stateDir}/bin`.
  stateDir ? "$HOME/.faforever", # cSpell:ignore faforever
  # Nix-provided Proton (a store path). Ignored when `protonPath` is set.
  proton ? proton-ge-bin.steamcompattool, # cSpell:words steamcompattool
  # Steam-installed Proton location (a host path). Takes precedence over `proton`.
  protonPath ? null,
  winetricksArgs ? [ ],
  # Commands to prepend before `umu-run`, e.g. `[ "gamemoderun" ]`.
  prefixCommands ? [ ],
  steamIntegration ? false,
  dxvkConf ? writeText "dxvk.conf" ''
    d3d9.evictManagedOnUnlock = True
    d3d9.floatEmulation = Strict
  '',
  ...
}:
let
  umu = umu-launcher.override {
    extraLibraries =
      pkgs: with pkgs; [
        libpulseaudio # cSpell:words libpulseaudio
        vulkan-loader
        freetype # cSpell:words freetype
        libxcomposite # cSpell:words libxcomposite
        libxrandr # cSpell:words libxrandr
        libxfixes # cSpell:words libxfixes
        libxcursor # cSpell:words libxcursor
        libxi
      ];
  };

  protonEnv = if protonPath != null then protonPath else "${proton}";

  tricksCommand =
    if (lib.length winetricksArgs) > 0 then
      "umu-run winetricks ${lib.escapeShellArgs winetricksArgs}"
    else
      ": # no winetricks set";

  prefixes = (lib.optional steamIntegration "steam-run") ++ prefixCommands;
  prefix = lib.optionalString (prefixes != [ ]) "${lib.concatStringsSep " " prefixes} ";

  # cSpell:ignore GAMEID PROTONPATH
  steamIntegrationEnv = lib.optionalString steamIntegration ''
    export ENABLE_VK_LAYER_VALVE_steam_overlay_1=1
    export SteamGameId=9420
    export SteamAppId=9420
  '';
in
assert lib.assertMsg (
  proton != null || protonPath != null
) "faf-game-launcher: one of `proton` or `protonPath` must be set";
writeShellApplication {
  name = "faf-game-launcher";

  runtimeInputs = [
    umu
    coreutils
  ]
  ++ lib.optional steamIntegration steam-run-free;

  text = ''
    export WINEPREFIX="$HOME/.wine/${prefixName}"
    export GAMEID=9420
    export STORE=steam
    export PROTONPATH="${protonEnv}"
    export WINE_LARGE_ADDRESS_AWARE=1
    export DXVK_CONFIG_FILE="${dxvkConf}"
    export DXVK_STATE_CACHE_PATH="$HOME/.local/state/downlords-faf-client/dxvk"
    ${steamIntegrationEnv}
    mkdir -p "$DXVK_STATE_CACHE_PATH"

    if [ ! -d "$WINEPREFIX" ]; then # if the prefix does not exist
      ${tricksCommand}
    fi

    cd "${stateDir}/bin" || exit 1

    exec ${prefix}umu-run "$@"
  '';

  meta = {
    description = "umu/Proton launcher for Supreme Commander: Forged Alliance, driven by the FAF client";
    mainProgram = "faf-game-launcher";
  };
}
