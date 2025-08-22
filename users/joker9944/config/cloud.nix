{
  config,
  lib,
  pkgs,
  ...
}:
let
  cloudDir = dir: "${config.home.homeDirectory}/.local/state/cloud/${dir}";

  mkdirBin = "${pkgs.coreutils}/bin/mkdir";
in
{
  xdg.userDirs = {
    enable = true;
    createDirectories = false;

    extraConfig = {
      XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
    };
  };

  home = {
    file = lib.attrsets.listToAttrs (
      lib.lists.map
        (dir: {
          name = dir;
          value = {
            source = config.lib.file.mkOutOfStoreSymlink (cloudDir dir);
            force = true;
          };
        })
        [
          "Documents"
          "Templates"
          "Music"
          "Pictures"
          "Videos"
        ]
    );

    activation.createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.strings.concatLines (
        lib.lists.map
          (dir: "if [ ! -d ~/${dir} ]; then run ${mkdirBin} $VERBOSE_ARG --mode=755 ~/${dir}; fi")
          [
            "Desktop"
            "Downloads"
            "Public"
            "Workspace"
          ]
      )
    );
  };
}
