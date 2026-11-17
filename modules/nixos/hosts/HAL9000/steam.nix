_:
{ pkgs, ... }:
{
  # GE-Proton only; a title opts out by setting either to 0.
  programs.steam.package = pkgs.steam.override {
    extraEnv = {
      PROTON_ENABLE_WAYLAND = "1";
      PROTON_FORCE_HDR = "1";
    };
  };
}
