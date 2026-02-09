{ lib, config, ... }:
{
  options.mixins.services.openssh =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "openssh config mixin";
    };

  config =
    let
      cfg = config.mixins.services.openssh;
    in
    lib.mkIf cfg.enable {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    };
}
