{ lib, config, ... }:
{
  options =
    let
      inherit (lib) mkEnableOption mkOption types;

      rasiLiteral =
        types.submodule {
          options = {
            _type = mkOption {
              type = types.enum [ "literal" ];
              internal = true;
            };

            value = mkOption {
              type = types.str;
              internal = true;
            };
          };
        }
        // {
          description = "Rasi literal string";
        };

      primitive =
        with types;
        (oneOf [
          str
          int
          bool
          rasiLiteral
        ]);

      configType = with types; (either (attrsOf (either primitive (listOf primitive))) str);

      themeType = with types; attrsOf configType;
    in
    {
      programs.wallust.templates.rofi = {
        enable = mkEnableOption "rofi wallust config";

        template = mkOption {
          type = themeType;

          description = ''
            Template for custom rofi theme.
          '';
        };
      };
    };

  config =
    let
      cfg = config.programs.wallust;

      # Taken from
      # https://github.com/nix-community/home-manager/blob/0d02ec1d0a05f88ef9e74b516842900c41f0f2fe/modules/programs/rofi.nix#L19-L71
      mkValueString =
        value:
        if lib.isBool value then
          if value then "true" else "false"
        else if lib.isInt value then
          lib.toString value
        else if (value._type or "") == "literal" then
          value.value
        else if lib.isString value then
          ''"${value}"''
        else if lib.isList value then
          "[ ${lib.strings.concatStringsSep "," (lib.map mkValueString value)} ]"
        else
          abort "Unhandled value type ${builtins.typeOf value}";

      mkKeyValue =
        {
          sep ? ": ",
          end ? ";",
        }:
        name: value: "${name}${sep}${mkValueString value}${end}";

      mkRasiSection =
        name: value:
        if lib.isAttrs value then
          let
            toRasiKeyValue = lib.generators.toKeyValue { mkKeyValue = mkKeyValue { }; };
            # Remove null values so the resulting config does not have empty lines
            configStr = toRasiKeyValue (lib.filterAttrs (_: v: v != null) value);
          in
          ''
            ${name} {
            ${configStr}}
          ''
        else
          (mkKeyValue {
            sep = " ";
            end = "";
          } name value)
          + "\n";

      toRasi =
        attrs:
        lib.concatStringsSep "\n" (
          lib.concatMap (lib.mapAttrsToList mkRasiSection) [
            (lib.filterAttrs (n: _: n == "@theme") attrs)
            (lib.filterAttrs (n: _: n == "@import") attrs)
            (lib.removeAttrs attrs [
              "@theme"
              "@import"
            ])
          ]
        );
    in
    lib.mkIf (cfg.enable && cfg.templates.rofi.enable) {
      xdg.configFile."wallust/templates/rofi.rasi".text = toRasi cfg.templates.rofi.template;

      programs.wallust.settings.templates.rofi = {
        template = "rofi.rasi";
        target = "~/.config/rofi/wallust.rasi";
      };

      programs.rofi.theme = "wallust";
    };
}
