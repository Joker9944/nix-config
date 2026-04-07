{
  lib,
  config,
  ...
}:
{
  options.mixins.services.pipewire =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "pipewire config mixin";
    };

  config =
    let
      cfg = config.mixins.services.pipewire;
    in
    lib.mkIf cfg.enable {
      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
}
