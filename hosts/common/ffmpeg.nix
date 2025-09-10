{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.ffmpeg;
in
{
  options.programs.ffmpeg = with lib; {
    enable = mkEnableOption "ffmpeg";
  };

  config = lib.mkIf cfg.enable {
    custom.nixpkgsCompat.allowUnfreePackages = [ "ffmpeg" ];

    environment.systemPackages = with pkgs; [
      (ffmpeg.override {
        withUnfree = true;
        withFdkAac = true;
      })
    ];
  };
}
