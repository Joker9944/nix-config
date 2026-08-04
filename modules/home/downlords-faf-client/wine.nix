{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.faf;
in
{
  options.programs.faf = with lib; {
    umu.package = mkPackageOption pkgs "umu-launcher" { };

    winetricksArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression ''
        [
          "--unattended"
          "d3dx9"
          "xact"
        ]
      '';
      description = ''
        Arguments passed to `umu-run winetricks` during wine prefix setup.

        Empty by default: Proton-GE bundles DXVK and its protonfixes handle the
        DirectX bits for Supreme Commander (appid 9420), so no manual verbs are
        usually needed. Add verbs here only if the prefix build turns out to need them.
      '';
    };

    wine.prefixName = mkOption {
      type = types.str;
      default = "faf";
      description = ''
        Name for the wine prefix that will be located at `~/.wine/''${prefixName}`.
      '';
    };

    wine.prefixCommands = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression ''
        [
          "gamemoderun"
          "gamescope"
          "--fullscreen"
          "--"
        ]
      '';
      description = ''
        Command to run before invoking umu.
      '';
    };

    steam.enable = mkEnableOption "steam integration";

    proton = {
      package = mkOption {
        type = types.nullOr types.package;
        default = pkgs.proton-ge-bin.steamcompattool; # cSpell:words steamcompattool
        defaultText = literalExpression "pkgs.proton-ge-bin.steamcompattool";
        example = literalExpression ''
          (pkgs.proton-ge-bin.overrideAttrs (old: rec {
            version = "GE-Proton10-34";
            src = pkgs.fetchzip {
              url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/''${version}/''${version}.tar.gz";
              hash = "sha256-...";
            };
          })).steamcompattool
        '';
        description = ''
          Proton package to run the game with. Set to `null` to use a
          Steam-installed Proton via `programs.faf.proton.path` instead.

          Override this to pin a specific Proton-GE version.
        '';
      };

      path = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = literalExpression "\${config.programs.faf.steam.library.path}/steamapps/common/Proton 10.0";
        description = ''
          Location of a Steam-installed Proton to use instead of
          `programs.faf.proton.package`. Takes precedence when set.
        '';
      };
    };

    dxvk.conf = mkOption {
      type = types.lines;
      default = ''
        # This will hopefully help with crashes due to running out of address space
        d3d9.evictManagedOnUnlock = True
        # Fix some broken effects
        d3d9.floatEmulation = Strict
      '';
      description = ''
        Config passed to DXVK.
      '';
    };
  };

  config =
    let
      wrapperHomePathPart = ".local/share/downlords-faf-client/wrapper.sh";

      launcher = pkgs.faf-game-launcher.override {
        inherit (cfg.wine) prefixName prefixCommands;
        inherit (cfg) winetricksArgs;

        umu-launcher = cfg.umu.package;
        stateDir = cfg.client.path;
        proton = cfg.proton.package;
        protonPath = cfg.proton.path;
        steamIntegration = cfg.steam.enable;
        dxvkConf = pkgs.writeText "dxvk.conf" cfg.dxvk.conf;
      };
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.proton.package != null) || (cfg.proton.path != null);
          message = "One of `programs.faf.proton.package` or `programs.faf.proton.path` must be set";
        }
      ];

      # Stable home path pointing at the launcher so the client does not overwrite
      # the actual store link by accident.
      home.file.${wrapperHomePathPart}.source = lib.getExe launcher;

      programs.faf.client.preferencesOverrides.forgedAlliance = {
        executableDecorator = lib.mkDefault "${config.home.homeDirectory}/${wrapperHomePathPart} \"%s\"";
        preferencesFile = lib.mkDefault "${config.home.homeDirectory}/.wine/${cfg.wine.prefixName}/drive_c/users/steamuser/AppData/Local/Gas Powered Games/Supreme Commander Forged Alliance/Game.prefs";
      };
    };
}
