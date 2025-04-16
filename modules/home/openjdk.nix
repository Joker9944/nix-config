{
  config,
  lib,
  pkgs-unstable,
  ...
}: let
  cfg = config.programs.openjdk;
  jdkVersions = versionNumbers: lib.map (versionNumber: "openjdk" + (toString versionNumber)) versionNumbers;
in {
  options.programs.openjdk = with lib; {
    versions = mkOption {
      type = types.listOf types.int;
      default = [];
      example = [11];
      description = ''
        Which versions of openjdk should be installed.
      '';
    };
  };

  config.home.file = lib.listToAttrs (lib.map (jdkVersion: {
    name = ".jdks/${jdkVersion}";
    value = {
      source = "${pkgs-unstable.${jdkVersion}}/lib/openjdk";
    };
  }) (jdkVersions cfg.versions));
}
