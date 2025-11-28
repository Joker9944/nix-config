{ lib, config, ... }:
{
  config = lib.mkIf config.programs.intelli-shell.enable {
    programs = {
      intelli-shell.settings.gist = {
        id = "8a3b4e4d4a58e3d71c939fcaab658aa0";
        token = ""; # GIST_TOKEN env variables takes precedence
      };

      bash.initExtra = ''
        export GIST_TOKEN="$(cat ${config.sops.secrets."tokens/intelli-shell".path})"
      '';
    };

    sops.secrets."tokens/intelli-shell" = { };
  };
}
