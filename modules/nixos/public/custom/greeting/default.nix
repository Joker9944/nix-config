_:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.custom.greeting;

  presets = {
    title = {
      format = "{user-name-colored}{at-symbol-colored}{host-name-colored}";
      color = {
        user = "default";
        host = cfg.color;
      };
    };
    uptime = {
      key = "up";
      format = "{?days}{days}d {?}{?hours}{hours}h {?}{minutes}m";
    };
    loadavg = {
      key = "load";
      format = "{loadavg1} {loadavg2} {loadavg3}";
    };
    memory = {
      key = "mem";
      format = "{used} / {total} ({percentage})";
    };
    disk = {
      key = "disk";
      hideFS = "zfs";
      format = "{mountpoint} {size-percentage} of {size-total}";
    };
    zpool = {
      key = "pool";
      format = "{name} {state} {used-percentage} of {size-total}";
    };
  };

  fastfetch =
    if lib.elem "zpool" cfg.modules then
      pkgs.fastfetch.override {
        zfsSupport = true;
        zfs = config.boot.zfs.package;
      }
    else
      pkgs.fastfetch;

  modules = lib.concatMap (
    name: [ ({ type = name; } // presets.${name}) ] ++ lib.optional (name == "title") "break"
  ) cfg.modules;
  # fastfetch's key.width counts the separator column; +1 more leaves a space before the value.
  keyWidth = 2 + lib.foldl' lib.max 0 (map (m: lib.stringLength (m.key or "")) modules);

  taglineHeight = if cfg.taglines == [ ] then 0 else 2;
  height =
    name:
    {
      title = 2;
      disk = cfg.diskCount;
    }
    .${name} or 1;
  infoHeight = lib.foldl' (n: name: n + height name) taglineHeight cfg.modules;
  artHeight = lib.length (lib.splitString "\n" (lib.removeSuffix "\n" cfg.art));
  gap = infoHeight - artHeight;

  mkConfig =
    taglines:
    pkgs.writeText "greeting.jsonc" (
      builtins.toJSON {
        logo = {
          type = "file";
          source = pkgs.writeText "greeting-art" cfg.art;
          color."1" = cfg.color;
          padding = {
            top = lib.max 0 (gap / 2);
            left = 2;
            right = 3;
          };
        };
        display = {
          brightColor = false;
          separator = " ";
          key.width = keyWidth;
        };
        modules = lib.replicate (lib.max 0 (-gap / 2)) "break" ++ taglines ++ modules;
      }
    );

  configs =
    if cfg.taglines == [ ] then
      [ (mkConfig [ ]) ]
    else
      map (
        tagline:
        mkConfig [
          {
            type = "title";
            format = "{#1}${tagline}{#}";
          }
          "break"
        ]
      ) cfg.taglines;

  greeting = pkgs.writeShellScriptBin "greeting" ''
    configs=(${lib.concatStringsSep " " configs})
    echo
    ${lib.getExe fastfetch} -c "''${configs[RANDOM % ''${#configs[@]}]}"
    echo
  '';
in
{
  options.custom.greeting = {
    enable = lib.mkEnableOption "interactive shell greeting";

    art = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Plain-text art printed left of the info block.
      '';
    };

    color = mkOption {
      type = types.enum [
        "black"
        "red"
        "green"
        "yellow"
        "blue"
        "magenta"
        "cyan"
        "white"
      ];
      default = "white";
      description = ''
        ANSI palette colour of the art.
      '';
    };

    taglines = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Bold line above the info block, one picked at random per greeting.
        A fastfetch `title` format string, e.g. `{user-name}`, `{host-name}`.
      '';
    };

    modules = mkOption {
      type = types.listOf (types.enum (lib.attrNames presets));
      default = [
        "title"
        "uptime"
      ];
      description = ''
        fastfetch modules of the info block, each with a compact key and format.
      '';
    };

    diskCount = mkOption {
      type = types.ints.unsigned;
      default = 1;
      description = ''
        Lines the `disk` module prints, one per mount fastfetch detects. Only used to centre the info block against the art.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ greeting ];

    programs.bash.interactiveShellInit = ''
      if [[ -z ''${GREETING_SHOWN:-} ]]; then
        export GREETING_SHOWN=1
        ${lib.getExe greeting}
      fi
    '';
  };
}
