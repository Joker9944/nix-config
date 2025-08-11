{
  lib,
  config,
  ...
}: let
  cfg = config.gnome-settings.keyboard.shortcuts;

  customShortcutOptions = {...}: {
    options = with lib; {
      name = mkOption {
        type = types.str;
        example = "Launch Console";
        description = ''
          The name of the custom shortcut.
        '';
      };

      command = mkOption {
        type = types.str;
        example = "kgx";
        description = ''
          The command that should be run when the shortcut is pressed.
        '';
      };

      binding = mkOption {
        type = types.str;
        example = "<Super>t";
        description = ''
          The shortcut binding.
        '';
      };
    };
  };

  mkCustomKeybindingKey = index: "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString index}";
  mkCustomKeybindingRef = index: "/" + (mkCustomKeybindingKey index) + "/";
in {
  options.gnome-settings.keyboard.shortcuts = with lib; {
    enable = mkEnableOption "Whether to enable GNOME keyboard shortcuts config.";

    customShortcuts = mkOption {
      type = types.listOf (types.submodule customShortcutOptions);
      default = [];
      example = literalExpression ''
        [
          {
            name = "Launch Console";
            command = "kgs";
            binding = "<Super>T";
          }
        ]
      '';
      description = ''
        List of custom shortcuts.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    let
      customKeybindingsRef = lib.lists.imap0 (index: _: mkCustomKeybindingRef index) cfg.customShortcuts;
      customKeybindings = lib.attrsets.listToAttrs (lib.lists.imap0 (index: customShortcut: {
          name = mkCustomKeybindingKey index;
          value = customShortcut;
        })
        cfg.customShortcuts);
    in {
      dconf.settings =
        {
          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = lib.mkIf (customKeybindingsRef != []) customKeybindingsRef;
        }
        // customKeybindings;
    }
  );
}
