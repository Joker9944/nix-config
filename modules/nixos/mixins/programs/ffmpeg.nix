{ mkMixinModule, ... }:
{ pkgs, ... }:
mkMixinModule "ffmpeg" {
  custom.nixpkgsCompat.allowUnfreePackages = [ "ffmpeg" ];

  environment.systemPackages = [
    (pkgs.ffmpeg.override {
      withUnfree = true;
      withFdkAac = true;
    })
  ];
}
