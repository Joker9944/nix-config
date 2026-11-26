_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.dua;
  tomlFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = with lib.hm.maintainers; [
    joker9944
  ];

  options.programs.dua =
    let
      inherit (lib)
        mkEnableOption
        mkPackageOption
        mkOption
        literalExpression
        ;
    in
    {
      enable = mkEnableOption "`dua` - a tool to learn about disk usage, fast";

      package = mkPackageOption pkgs "dua" {
        nullable = true;
      };

      settings = mkOption {
        inherit (tomlFormat) type;
        default = { };
        example = literalExpression ''
          {
            keys.esc_navigates_back = true;
          }
        '';
        description = ''
          Configuration written to {file}`$XDG_CONFIG_HOME/dua-cli/config.toml`.
          See <https://github.com/Byron/dua-cli> for available options.
        '';
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;

    xdg.configFile."dua-cli/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "dua-config.toml" cfg.settings;
    };
  };
}
