{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.mixins.programs.utilities =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "utilities config mixin";
    };

  config.environment.systemPackages = lib.optionals config.mixins.programs.utilities.enable (
    with pkgs;
    [
      # commands
      curl
      wget
      dig
      jq
      yq
      openssl
      pciutils
      file

      # languages
      python3
    ]
  );
}
