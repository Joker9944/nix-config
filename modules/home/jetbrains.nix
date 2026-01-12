{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.programs.jetbrains =
    let
      inherit (lib)
        mkOption
        mkEnableOption
        types
        literalExpression
        ;
    in
    mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "jetbrains product config";

            package = mkOption {
              type = types.nullOr types.package;
              default = null;
              description = ''
                The product package to use.
              '';
            };

            vmoptions = mkOption {
              type = types.listOf (
                types.oneOf [
                  types.str
                  types.attrs
                ]
              );
              default = [ ];
              example = literalExpression ''
                [
                  "-Xmx4096m"
                  { "-Dawt.toolkit.name" = "WLToolkit"; }
                ]
              '';
              description = ''
                JVM options to run product.
              '';
            };
          };
        }
      );
      default = { };
      example = literalExpression ''
        {
          idea = {
            enable = true;

            vmoptions = [
              "-Xmx4096m"
              { "-Dawt.toolkit.name" = "WLToolkit"; }
            ];
          };
        }
      '';
      description = ''
        JetBrains product config module.
      '';
    };

  config =
    let
      products = lib.pipe config.programs.jetbrains [
        lib.attrsToList
        (lib.filter (product: product.value.enable))
      ];

      stubsLookup = {
        idea = {
          name = "IntelliJIdea";
          short = "idea64";
        };

        webstorm = {
          name = "WebStorm";
          short = "webstorm64";
        };
      };

      determinePackage =
        name: package: if lib.isDerivation package then package else pkgs.jetbrains.${name};
    in
    {
      home.packages = lib.map (product: determinePackage product.name product.value.package) products;

      xdg.configFile = lib.pipe products [
        (lib.filter (product: product.value.vmoptions != [ ]))
        (lib.map (
          product:
          let
            inherit (product) name;
            cfg = product.value;
            package = determinePackage name cfg.package;
            stubs = stubsLookup.${package.pname};
            versionParts = lib.splitString "." package.version;
            versionStub = "${lib.elemAt versionParts 0}.${lib.elemAt versionParts 1}";
          in
          {
            name = "JetBrains/${stubs.name}${versionStub}/${stubs.short}.vmoptions";
            value = {
              text = lib.pipe cfg.vmoptions [
                (lib.map (
                  vmoption:
                  if lib.isAttrs vmoption then
                    lib.mapAttrsToList (name: value: "${name}=${toString value}") vmoption
                  else
                    vmoption
                ))
                lib.flatten
                lib.concatLines
              ];
            };
          }
        ))
        lib.listToAttrs
      ];
    };
}
