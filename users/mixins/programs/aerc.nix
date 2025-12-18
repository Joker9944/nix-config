{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.mixins.programs.aerc =
    let
      inherit (lib) mkEnableOption;
    in
    {
      enable = mkEnableOption "aerc config mixin";
    };

  config.programs.aerc =
    let
      cfg = config.mixins.programs.aerc;
    in
    lib.mkIf cfg.enable {
      extraConfig = {
        viewer.pager = "${lib.getExe pkgs.moor} --no-statusbar --no-linenumbers";

        ui = {
          icon-encrypted = "✔";
          icon-signed = "✔";
          icon-signed-encrypted = "✔";
          icon-unknown = "✘";
          icon-invalid = "⚠";
        };
      };

      extraBinds = {
        messages = {
          q = ":quit<Enter>";
        };
      };
    };
}
