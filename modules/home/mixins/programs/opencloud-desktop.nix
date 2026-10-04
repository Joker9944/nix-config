{ mkMixinModule, ... }:
{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
mkMixinModule "opencloud-desktop" {
  programs.opencloud-desktop = {
    enable = true;

    # HACK: kdsingleapplication appends XDG_SESSION_ID to its IPC socket name only when the var is
    # set, so an instance launched where it is absent (vicinae) never finds the autostarted one and
    # deadlocks on its sync-database lock; unsetting it puts every launch context in one namespace
    package =
      let
        inherit (pkgs-unstable) opencloud-desktop;
      in
      pkgs.symlinkJoin {
        name = "opencloud-desktop-session-agnostic-${opencloud-desktop.version}";
        paths = [ opencloud-desktop ];
        nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/opencloud" --unset XDG_SESSION_ID
        '';
        inherit (opencloud-desktop) meta version;
      };
  };

  # shares the program's package so the unit and the profile cannot land in different IPC namespaces
  services.opencloud-desktop = {
    enable = true;
    inherit (config.programs.opencloud-desktop) package;
  };

  xdg = {
    # HACK: upstream installs opencloudcmd.desktop byte-identical to opencloud.desktop, so the
    # launcher lists the GUI twice; this entry wins the profile collision and hides the copy
    desktopEntries.opencloudcmd = {
      name = "OpenCloud Desktop sync client (CLI)";
      exec = "opencloudcmd";
      terminal = true;
      noDisplay = true;
    };

    userDirs = {
      enable = true;

      extraConfig = {
        GAMES = "${config.home.homeDirectory}/Games";
        NOTES = "${config.home.homeDirectory}/Notes";
      };
    };
  };

  home =
    let
      cloudDir = "${config.xdg.stateHome}/cloud/Personal";
      mkCloudDirPath = dir: "${cloudDir}/${dir}";
      cloudDirStubs = lib.map (lib.removePrefix "${config.home.homeDirectory}/") [
        config.xdg.userDirs.documents
        config.xdg.userDirs.templates
        config.xdg.userDirs.music
        config.xdg.userDirs.pictures
        config.xdg.userDirs.videos
        config.xdg.userDirs.extraConfig.GAMES
        config.xdg.userDirs.extraConfig.NOTES
      ];
    in
    {
      file = lib.pipe cloudDirStubs [
        (lib.map (dir: {
          name = dir;
          value = {
            source = config.lib.file.mkOutOfStoreSymlink (mkCloudDirPath dir);
            force = true;
          };
        }))
        lib.listToAttrs
      ];

      activation.createCloudDirectory = lib.hm.dag.entryBefore [ "createXdgUserDirectories" ] (
        lib.pipe cloudDirStubs [
          (lib.map mkCloudDirPath)
          (lib.map (dir: ''[[ -d "${dir}" ]] || run mkdir -p $VERBOSE_ARG "${dir}"''))
          lib.concatLines
        ]
      );
    };
}
