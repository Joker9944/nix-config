{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.faf;
  format.json = pkgs.formats.json { };
in
{
  imports = [
    ./wine.nix
  ];

  options.programs.faf = with lib; {
    enable = mkEnableOption "FAForever client";
    package = mkPackageOption pkgs "downlords-faf-client" { };

    client = {
      path = mkOption {
        type = types.path;
        default = "${config.home.homeDirectory}/.faforever";
        defaultText = literalExpression "\${config.home.homeDirectory}/.faforever";
        description = ''
          Location of the FAForever client state dir.
        '';
      };

      preferencesOverrides = mkOption {
        inherit (format.json) type;
        default = { };
        example = literalExpression ''
          {
            matchmaker = {
              factions = [ "aeon" "seraphim" ];
            };
          }
        '';
        description = ''
          Overrides for the FAFClient `~/.faforever/client.prefs`.

          Please note that these values will not be linked from store but overridden on every switch.
          This is because the client not only stores preferences but also state in the preferences file, so the file cannot be fully manged from the nix store.
          If switch is run while the client is running in the background the client will overwrite changes maybe by Home Manager since preferences are cached in memory by the client.
        '';
      };
    };

    steam = {
      path = mkOption {
        type = types.path;
        default = "${config.home.homeDirectory}/.local/share/Steam";
        defaultText = "\${config.home.homeDirectory}/.local/share/Steam";
        description = ''
          Location of the steam state dir.
        '';
      };

      library.path = mkOption {
        type = types.path;
        default = cfg.steam.path;
        defaultText = "config.programs.faf.steam.path";
        example = "/mnt/games/SteamLibrary";
        description = ''
          Location of the steam library containing Proton and Supreme Commander Forged Alliance.

          If Proton and the game exist in different libraries please use the specific path overrides.
        '';
      };
    };

    supComFA.path = mkOption {
      type = types.path;
      default = "${cfg.steam.library.path}/steamapps/common/Supreme Commander Forged Alliance";
      defaultText = literalExpression "\${config.programs.faf.steam.library.path}/steamapps/common/Supreme Commander Forged Alliance";
      example = "/mnt/games/SteamLibrary/steamapps/common/Supreme Commander Forged Alliance";
      description = ''
        Location of Supreme Command Forged Alliance.
      '';
    };
  };

  config =
    let
      bin = {
        jq = lib.getExe pkgs.jq;
        sponge = lib.getExe' pkgs.moreutils "sponge";
      };

      clientPrefs = "${cfg.client.path}/client.prefs";

      overridePrefs = format.json.generate "client-override.prefs" cfg.client.preferencesOverrides;
    in
    lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      programs.faf.client.preferencesOverrides = {
        forgedAlliance = {
          installationPath = lib.mkDefault cfg.supComFA.path;
        };
      };

      # In-place deep merge client.prefs with client-override.prefs
      home.activation.overrideClientPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${bin.jq} --slurp '.[0] * .[1]' "${clientPrefs}" "${overridePrefs}" | ${bin.sponge} "${clientPrefs}"
      '';
    };
}
