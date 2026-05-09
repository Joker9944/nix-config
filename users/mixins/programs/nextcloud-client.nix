{ lib, config, ... }:
{
  options.mixins.programs.nextcloud-client =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "nextcloud-client config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.nextcloud-client;
      mkCloudDir = dir: "${config.home.homeDirectory}/.local/state/cloud/${dir}";
    in
    lib.mkIf cfg.enable {
      programs.nextcloud-client.enable = true;

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = lib.mkForce false;

        extraConfig.XDG_NOTES_DIR = "${config.home.homeDirectory}/Notes";
      };

      home = {
        file =
          lib.pipe
            [
              config.xdg.userDirs.documents
              config.xdg.userDirs.templates
              config.xdg.userDirs.music
              config.xdg.userDirs.pictures
              config.xdg.userDirs.videos
              config.xdg.userDirs.extraConfig.XDG_NOTES_DIR
            ]
            [
              (lib.map (lib.removePrefix "${config.home.homeDirectory}/"))
              (lib.map (dir: {
                name = dir;
                value = {
                  source = config.lib.file.mkOutOfStoreSymlink (mkCloudDir dir);
                  force = true;
                };
              }))
              lib.listToAttrs
            ];

        activation.createXdgUserDirectories = lib.hm.dag.entryAfter [ "linkGeneration" ] (
          lib.pipe
            (
              [
                config.xdg.userDirs.desktop
                config.xdg.userDirs.download
                config.xdg.userDirs.publicShare
              ]
              ++ lib.pipe config.xdg.userDirs.extraConfig [
                (lib.filterAttrs (name: _: name != "XDG_NOTES_DIR"))
                lib.attrValues
              ]
            )
            [
              (lib.map (dir: "[[ -d \"${dir}\" ]] || run mkdir -p $VERBOSE_ARG \"${dir}\""))
              lib.concatLines
            ]
        );
      };
    };
}
