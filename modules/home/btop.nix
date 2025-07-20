{config, lib, pkgs, ...}: let
  name = "btop++";
  cfg = config.programs.btop;
in {
  options.programs.btop = with lib; {
    enable = mkEnableOption name;
    package = mkPackageOption pkgs.btop name;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
  };
}
