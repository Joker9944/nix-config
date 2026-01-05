{ lib, config, ... }:
{
  options.mixins.programs._1password =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "1Password config mixin";
    };

  config =
    let
      cfg = config.mixins.programs._1password;
    in
    lib.mkIf cfg.enable {
      custom.nixpkgsCompat.allowUnfreePackages = [
        "1password"
        "1password-cli"
      ];

      programs = {
        _1password.enable = true;

        _1password-gui = {
          enable = true;

          polkitPolicyOwners = lib.attrNames config.users.users;
        };
      };
    };
}
