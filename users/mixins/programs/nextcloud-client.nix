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
    in
    lib.mkIf cfg.enable {
      programs.nextcloud-client.enable = true;

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };

      xdg.userDirs = {
        enable = true;

        extraConfig.NOTES = "${config.home.homeDirectory}/Notes";
      };

      home =
        let
          cloudDir = "${config.home.homeDirectory}/.local/state/cloud";
          mkCloudDir = dir: "${cloudDir}/${dir}";
          cloudDirStubs = lib.map (lib.removePrefix "${config.home.homeDirectory}/") [
            config.xdg.userDirs.documents
            config.xdg.userDirs.templates
            config.xdg.userDirs.music
            config.xdg.userDirs.pictures
            config.xdg.userDirs.videos
            config.xdg.userDirs.extraConfig.NOTES
          ];
        in
        {
          file = lib.pipe cloudDirStubs [
            (lib.map (dir: {
              name = dir;
              value = {
                source = config.lib.file.mkOutOfStoreSymlink (mkCloudDir dir);
                force = true;
              };
            }))
            lib.listToAttrs
          ];

          activation.createCloudDirectory = lib.hm.dag.entryBefore [ "createXdgUserDirectories" ] (
            lib.pipe cloudDirStubs [
              (lib.map mkCloudDir)
              (lib.map (dir: ''[[ -d "${dir}" ]] || run mkdir -p $VERBOSE_ARG "${dir}"''))
              lib.concatLines
            ]
          );
        };
    };
}
