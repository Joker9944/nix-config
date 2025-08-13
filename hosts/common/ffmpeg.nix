{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.ffmpeg;
in {
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
