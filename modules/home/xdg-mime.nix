{
  lib,
  config,
  ...
}:
let
  cfg = config.xdg.mimeApps;
in
{
  options.xdg.mimeApps.custom =
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      apps = {
        default = mkOption {
          type = types.listOf types.path;
          default = [ ];
          example = literalExpression ''
            apps.default = [ \"''${config.programs.papers.package}/share/applications/org.gnome.Papers.desktop\" ]
          '';
          description = ''
            Paths of desktop files from which mime types should be set.
          '';
        };
        associations.added = mkOption {
          type = types.listOf types.path;
          default = [ ];
          example = literalExpression ''
            apps.default = [ \"''${config.programs.papers.package}/share/applications/org.gnome.Papers.desktop\" ]
          '';
          description = ''
            Paths of desktop files from which mime types should be set.
          '';
        };
      };
      mime.default = mkOption {
        type = types.attrsOf (types.attrsOf (types.listOf types.str));
        default = { };
        example = literalExpression ''
          mime.default.application.pdf = [ "org.gnome.Papers.desktop" ];
        '';
        description = ''
          Mime types in the `Default Applications` section.
        '';
      };
    };

  config.xdg.mimeApps =
    let
      deepMergeConcat =
        attrsets:
        lib.foldl (
          acc: attrset:
          acc
          // (lib.mapAttrs (
            name: value: if lib.hasAttr name acc then acc.${name} ++ value else value
          ) attrset)
        ) { } attrsets;
      # from app
      extractMimeTypesFromDesktopFileContent =
        content:
        lib.pipe content [
          (lib.match ".*MimeType[[:space:]]*=[[:space:]]*([^[:space:]]+).*")
          (match: lib.elemAt match 0)
          (lib.splitString ";")
          (lib.filter (mimeType: mimeType != ""))
        ];
      mapMimeTypesToDesktopFile =
        mimeTypes: desktopFile:
        lib.pipe mimeTypes [
          (lib.map (mimeType: {
            name = mimeType;
            value = [ desktopFile ];
          }))
          lib.listToAttrs
        ];
      mapAppsTypes =
        desktopFiles:
        lib.pipe desktopFiles [
          (lib.map (
            desktopFile:
            let
              desktopFileContent = lib.readFile desktopFile;
              desktopFileName = builtins.baseNameOf desktopFile;
            in
            mapMimeTypesToDesktopFile (extractMimeTypesFromDesktopFileContent desktopFileContent) desktopFileName
          ))
          deepMergeConcat
        ];
      # from mime
      mapMimeTypes = lib.concatMapAttrs (
        type: subtypes:
        lib.concatMapAttrs (subtype: applications: {
          "${type}/${subtype}" = applications;
        }) subtypes
      );
    in
    lib.mkIf cfg.enable {
      defaultApplications =
        (mapAppsTypes cfg.custom.apps.default) // (mapMimeTypes cfg.custom.mime.default);
      associations.added = mapAppsTypes cfg.custom.apps.associations.added;
    };
}
