{ config, lib, pkgs, ... }:

let
  nextcloudDir = dir: "${config.home.homeDirectory}/.local/state/cloud/${dir}";

  mkdirBin = "${ pkgs.coreutils }/bin/mkdir";
in {

  xdg.userDirs = {
    enable = true;
    createDirectories = false;

    extraConfig = {
      XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
    };
  };

  home = {

    file = {

      "Documents" = {
        source = config.lib.file.mkOutOfStoreSymlink ( nextcloudDir "Documents" );
        force = true;
      };

      "Templates" = {
        source = config.lib.file.mkOutOfStoreSymlink ( nextcloudDir "Templates" );
        force = true;
      };

      "Music" = {
        source = config.lib.file.mkOutOfStoreSymlink ( nextcloudDir "Music" );
        force = true;
      };

      "Pictures" = {
        source = config.lib.file.mkOutOfStoreSymlink ( nextcloudDir "Pictures" );
        force = true;
      };

      "Videos" = {
        source = config.lib.file.mkOutOfStoreSymlink ( nextcloudDir "Videos" );
        force = true;
      };

    };

    activation.createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ~/Desktop ]; then run ${ mkdirBin } $VERBOSE_ARG --mode=755 ~/Desktop; fi
      if [ ! -d ~/Downloads ]; then run ${ mkdirBin } $VERBOSE_ARG --mode=755 ~/Downloads; fi
      if [ ! -d ~/Public ]; then run ${ mkdirBin } $VERBOSE_ARG --mode=755 ~/Public; fi
      if [ ! -d ~/Workspace ]; then run ${ mkdirBin } $VERBOSE_ARG --mode=755 ~/Workspace; fi
    '';

  };

}
