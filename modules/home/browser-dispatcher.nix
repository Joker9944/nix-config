{
  lib,
  config,
  pkgs,
  custom,
  ...
}:
{
  options.custom.browser-dispatcher =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "browser dispatcher script";

      defaultBrowserCommand = mkOption {
        type = types.str;
        example = "librewolf --name librewolf \"$URL\"";
      };

      sites = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              patterns = mkOption {
                type = types.listOf types.str;
                example = literalExpression "[ \"https://youtube.com/*\" \"https://*.youtube.com/*\" \"https://youtu.be/*\" ]";
                default = [ ];
              };

              command = mkOption {
                type = types.str;
                example = "firefoxpwa site launch youtube \"$URL\"";
              };
            };
          }
        );
        default = [ ];
      };
    };

  config =
    let
      cfg = config.custom.browser-dispatcher;

      dispatcherPackage = pkgs.symlinkJoin {
        name = "browser-dispatcher";
        paths = [
          (pkgs.writeShellApplication {
            name = "browser-dispatcher";

            text = ''
              URL="$1"

              case "$URL" in
            ''
            + (lib.pipe cfg.sites [
              (lib.map (site: ''
                ${lib.join "|" site.patterns})
                  ${site.command}
                  ;;
              ''))
              (lib.concatStringsSep "\n")
              (custom.lib.indentLines 2)
            ])
            + ''
              esac
            '';
          })
          (pkgs.makeDesktopItem {
            desktopName = "browser-dispatcher";
            name = "browser-dispatcher";
            exec = "browser-dispatcher %U";
            mimeTypes = [
              "x-scheme-handler/http"
              "x-scheme-handler/https"
            ];
            noDisplay = true;
          })
        ];
      };
    in
    lib.mkIf cfg.enable {
      custom.browser-dispatcher.sites = lib.mkOrder 2000 [
        {
          patterns = [ "*" ];
          command = cfg.defaultBrowserCommand;
        }
      ];

      xdg.mimeApps.custom.apps.default = lib.mkOrder 10 [
        "${dispatcherPackage}/share/applications/browser-dispatcher.desktop"
      ];

      home.packages = [ dispatcherPackage ];
    };
}
