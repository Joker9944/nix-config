{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.ffmpeg =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "ffmpeg config mixin";
    };

  config =
    let
      cfg = config.mixins.programs.ffmpeg;
    in
    lib.mkIf cfg.enable {
      custom.nixpkgsCompat.allowUnfreePackages = [ "ffmpeg" ];

      environment.systemPackages = [
        (pkgs.ffmpeg.override {
          withUnfree = true;
          withFdkAac = true;
        })
      ];
    };
}
