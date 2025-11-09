{
  lib,
  config,
  pkgs,
  ...
}:
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
      cloudDir = dir: "${config.home.homeDirectory}/.local/state/cloud/${dir}";

      bin.mkdir = lib.getExe' pkgs.coreutils "mkdir";
    in
    lib.mkIf cfg.enable {
      programs.nextcloud-client.enable = true;

      services.nextcloud-client = {
        enable = true;
        startInBackground = true;
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = false;

        extraConfig = {
          XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
          XDG_NOTES_DIR = "${config.home.homeDirectory}/Notes";
        };
      };

      home = {
        file =
          lib.pipe
            [
              "Documents"
              "Templates"
              "Notes"
              "Music"
              "Pictures"
              "Videos"
            ]
            [
              (lib.map (dir: {
                name = dir;
                value = {
                  source = config.lib.file.mkOutOfStoreSymlink (cloudDir dir);
                  force = true;
                };
              }))
              lib.listToAttrs
            ];

        activation.createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.pipe
            [
              "Desktop"
              "Downloads"
              "Public"
              "Workspace"
            ]
            [
              (lib.map (dir: "if [ ! -d ~/${dir} ]; then run ${bin.mkdir} $VERBOSE_ARG --mode=755 ~/${dir}; fi"))
              lib.concatLines
            ]
        );
      };
    };
}
