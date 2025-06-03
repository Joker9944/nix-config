{
  lib,
  config,
  ...
}: let
  cfg = config.gnome-settings.gnome-online-accounts;
in {
  options.gnome-settings.gnome-online-accounts = with lib; {
    enable = mkEnableOption "Whether to enable GNOME online accounts config.";
    accounts = mkOption {
      type = with types; attrsOf attrs;
      default = {};
      example = literalExpression ''
        {
          "account_1745833011_0" = {
            Provider = "google";
            Identity = "example@gmail.com";
            PresentationIdentity = "example@gmail.com";
            MailEnabled = true;
            CalendarEnabled = true;
            ContactsEnabled = true;
            FilesEnabled = true;
          };
        };
      '';
      description = ''
        Online accounts to be added.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."goa-1.0/accounts.conf".text =
      lib.generators.toINI {
        mkSectionName = name: lib.escape ["[" "]"] ("Account " + name);
      }
      cfg.accounts;
  };
}
