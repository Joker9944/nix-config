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
    package = pkgs-unstable.opencloud-desktop;
  };

  xdg = {
    # WORKAROUND: the app writes its own entry from /proc/self/exe, which is the binary behind the
    # Nix wrapper, so the entry has to be declared here instead
    autostart.entries =
      let
        inherit (config.programs.opencloud-desktop) package;
        desktopFile = "share/applications/OpenCloud.desktop";
        entry = pkgs.runCommandLocal "opencloud-desktop-autostart-entry" { } ''
          install -Dm444 "${package}/share/applications/opencloud.desktop" "$out/${desktopFile}"
          substituteInPlace "$out/${desktopFile}" \
            --replace-fail "opencloud --showsettings" "opencloud"
        '';
      in
      [ "${entry}/${desktopFile}" ];

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
