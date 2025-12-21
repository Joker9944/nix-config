{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.isd;
  yamlFormat = pkgs.formats.yaml { };
in
{
  meta.maintainers = with lib.hm.maintainers; [
    joker9944
  ];

  options.programs.isd =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "`isd` - a better way to work with `systemd` units";

      package = mkPackageOption pkgs "isd" {
        nullable = true;
      };

      config = mkOption {
        inherit (yamlFormat) type;
        default = { };
        example = literalExpression ''
          startup_mode = "system";
          journal_pager = "lnav";
        '';
        description = ''
          Configuration for isd. Config reference can be found here:
          <https://kainctl.github.io/isd/customization/>
        '';
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;

    xdg.configFile."isd_tui/config.yaml" = lib.mkIf (cfg.config != { }) {
      source = yamlFormat.generate "isd-config.yaml" cfg.config;
    };
  };
}
