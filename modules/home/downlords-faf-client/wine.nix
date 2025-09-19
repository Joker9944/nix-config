{
  lib,
  pkgs,
  config,
  utility,
  ...
}:
let
  cfg = config.programs.faf;
  wrapWine = utility.custom.wrapWine { inherit pkgs; };
in
{
  options.programs.faf = with lib; {
    wine = {
      package = mkPackageOption pkgs "wine" { };

      prefixName = mkOption {
        type = types.str;
        default = "faf";
        description = ''
          Name for the wine prefix that will be located at `~/.wine/''${prefixName}`.
        '';
      };

      # cSpell:words xact
      winetricksArgs = mkOption {
        type = types.listOf types.str;
        default = [
          "--unattended"
          "d3dx9"
          "xact"
        ];
        description = ''
          Arguments for `winetricks` during wine prefix setup.
        '';
      };

      prefixCommands = mkOption {
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
          Command to run before invoking wine.
        '';
      };
    };

    steam.enable = mkEnableOption "steam integration";

    proton = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.proton-ge-bin";
        description = ''
          Custom Proton package to use.
        '';
      };

      path = mkOption {
        type = types.nullOr types.path;
        default = "${cfg.steam.library.path}/steamapps/common/Proton - Experimental";
        defaultText = literalExpression "\${config.programs.faf.steam.library.path}/steamapps/common/Proton - Experimental";
        example = literalExpression "\${config.programs.faf.steam.library.path}/steamapps/common/Proton 10.0";
        description = ''
          Location of the Proton version to use.
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
      bin = {
        setup_dxvk = lib.getExe pkgs.dxvk.out;
        cp = lib.getExe' pkgs.coreutils "cp";
        steam-run = lib.getExe pkgs.steam-run-free;
      };

      dxvkConfPathPart = ".config/downlords-faf-client/dxvk.conf";
      dxvkCachePathPart = ".local/state/downlords-faf-client/dxvk";
      wrapperHomePathPart = ".local/share/downlords-faf-client/wrapper.sh";

      # Making sure only one is set with assertions
      #protonPath = if cfg.proton.package != null then cfg.proton.package else cfg.proton.path;

      steamIntegrationSetup = lib.optionalString cfg.steam.enable ''
        export ENABLE_VK_LAYER_VALVE_steam_overlay_1=1
        export SteamGameId=9420
        export SteamAppId=9420
      '';

      # cSpell:ignore GAMEID PROTONPATH
      setup =
        let
          geProton =
            (pkgs.proton-ge-bin.overrideAttrs (oldAttrs: rec {
              version = "GE-Proton9-27";
              src = pkgs.fetchzip {
                url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
                hash = "sha256-70au1dx9co3X+X7xkBCDGf1BxEouuw3zN+7eDyT7i5c=";
              };
            })).steamcompattool; # cSpell:words steamcompattool
        in
        steamIntegrationSetup
        + ''
          export GAMEID=9420
          export STORE=steam
          export PROTONPATH="${geProton}"
          export DXVK_CONFIG_FILE="${config.home.homeDirectory}/${dxvkConfPathPart}"
          export DXVK_STATE_CACHE_PATH="${config.home.homeDirectory}/${dxvkCachePathPart}"
          export WINE_LARGE_ADDRESS_AWARE=1
        '';

      wrapper = wrapWine {
        inherit (cfg.wine) prefixName winetricksArgs;

        wine = cfg.wine.package;

        setupScript = setup;

        chdir = "${cfg.client.path}/bin";

        # steam-run supplies all necessary libs for steam integration
        prefixCommands = (lib.optional cfg.steam.enable "${bin.steam-run}") ++ cfg.wine.prefixCommands;
      };
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.proton.package != null) != (cfg.proton.path != null);
          message = "Exactly one of `programs.faf.proton.package` or `programs.faf.proton.path` must be set";
        }
      ];

      home.file = {
        ${dxvkConfPathPart}.text = cfg.dxvk.conf;
        # Making generic wrapper link in home so the client does not overwrite the actual wrapper link by accident
        ${wrapperHomePathPart}.source = "${wrapper}/bin/${cfg.wine.prefixName}";
      };

      programs.faf.client.preferencesOverrides.forgedAlliance = {
        executableDecorator = lib.mkDefault "${config.home.homeDirectory}/${wrapperHomePathPart} \"%s\"";
        preferencesFile = lib.mkDefault "${config.home.homeDirectory}/.wine/${cfg.wine.prefixName}/drive_c/users/steamuser/AppData/Local/Gas Powered Games/Supreme Commander Forged Alliance/Game.prefs";
      };
    };
}
