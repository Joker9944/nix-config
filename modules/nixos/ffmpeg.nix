{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.ffmpeg;
in {
  # TODO migrate to hosts common

  options.programs.ffmpeg = with lib; {
    enable = mkEnableOption "ffmpeg";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (ffmpeg.override {
        withUnfree = true;
        withFdkAac = true;
      })
    ];
  };
}
