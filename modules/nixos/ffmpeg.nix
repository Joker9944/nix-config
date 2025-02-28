{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ffmpeg;
in {

  options.programs.ffmpeg = with lib; {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable ffmpeg.
      '';
    };

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      ( ffmpeg.override {
        withUnfree = true;
        withFdkAac = true;
      } )
    ];

  };

}
