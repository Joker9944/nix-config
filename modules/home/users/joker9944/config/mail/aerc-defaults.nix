{ lib, ... }:
{
  programs.aerc = {
    extraConfig.filters = {
      "text/plain" = lib.mkDefault "colorize";
      "text/calendar" = lib.mkDefault "calendar";
      "message/delivery-status" = lib.mkDefault "colorize";
      "message/rfc822" = lib.mkDefault "colorize";
      "text/html" = lib.mkDefault "! html";

      # This special filter is only used to post-process email headers when
      # [viewer].show-headers=true
      # By default, headers are piped directly into the pager.
      ".headers" = lib.mkDefault "colorize";
    };

    extraBinds = {
      global = {
        "<C-p>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-PgUp>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-n>" = lib.mkDefault ":next-tab<Enter>";
        "<C-PgDn>" = lib.mkDefault ":next-tab<Enter>";
        "\\[t" = lib.mkDefault ":prev-tab<Enter>";
        "\\]t" = lib.mkDefault ":next-tab<Enter>";
        "<C-t>" = lib.mkDefault ":term<Enter>";
        "?" = lib.mkDefault ":help keys<Enter>";
        "<C-c>" = lib.mkDefault ":prompt 'Quit?' quit<Enter>";
        "<C-q>" = lib.mkDefault ":prompt 'Quit?' quit<Enter>";
        "<C-z>" = lib.mkDefault ":suspend<Enter>";
      };

      messages = {
        "q" = lib.mkDefault ":prompt 'Quit?' quit<Enter>";
        "j" = lib.mkDefault ":next<Enter>";
        "<Down>" = lib.mkDefault ":next<Enter>";
        "<C-d>" = lib.mkDefault ":next 50%<Enter>";
        "<C-f>" = lib.mkDefault ":next 100%<Enter>";
        "<PgDn>" = lib.mkDefault ":next 100%<Enter>";
        "k" = lib.mkDefault ":prev<Enter>";
        "<Up>" = lib.mkDefault ":prev<Enter>";
        "<C-u>" = lib.mkDefault ":prev 50%<Enter>";
        "<C-b>" = lib.mkDefault ":prev 100%<Enter>";
        "<PgUp>" = lib.mkDefault ":prev 100%<Enter>";
        "g" = lib.mkDefault ":select 0<Enter>";
        "G" = lib.mkDefault ":select -1<Enter>";
        "J" = lib.mkDefault ":next-folder<Enter>";
        "<C-Down>" = lib.mkDefault ":next-folder<Enter>";
        "K" = lib.mkDefault ":prev-folder<Enter>";
        "<C-Up>" = lib.mkDefault ":prev-folder<Enter>";
        "H" = lib.mkDefault ":collapse-folder<Enter>";
        "<C-Left>" = lib.mkDefault ":collapse-folder<Enter>";
        "L" = lib.mkDefault ":expand-folder<Enter>";
        "<C-Right>" = lib.mkDefault ":expand-folder<Enter>";
        "v" = lib.mkDefault ":mark -t<Enter>";
        "<Space>" = lib.mkDefault ":mark -t<Enter>:next<Enter>";
        "V" = lib.mkDefault ":mark -v<Enter>";
        "T" = lib.mkDefault ":toggle-threads<Enter>";
        "zc" = lib.mkDefault ":fold<Enter>";
        "zo" = lib.mkDefault ":unfold<Enter>";
        "za" = lib.mkDefault ":fold -t<Enter>";
        "zM" = lib.mkDefault ":fold -a<Enter>";
        "zR" = lib.mkDefault ":unfold -a<Enter>";
        "<tab>" = lib.mkDefault ":fold -t<Enter>";
        "zz" = lib.mkDefault ":align center<Enter>";
        "zt" = lib.mkDefault ":align top<Enter>";
        "zb" = lib.mkDefault ":align bottom<Enter>";
        "<Enter>" = lib.mkDefault ":view<Enter>";
        "d" = lib.mkDefault ":choose -o y 'Really delete this message' delete-message<Enter>";
        "D" = lib.mkDefault ":delete<Enter>";
        "a" = lib.mkDefault ":archive flat<Enter>";
        "A" = lib.mkDefault ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";
        "C" = lib.mkDefault ":compose<Enter>";
        "m" = lib.mkDefault ":compose<Enter>";
        "b" = lib.mkDefault ":bounce<space>";
        "rr" = lib.mkDefault ":reply -a<Enter>";
        "rq" = lib.mkDefault ":reply -aq<Enter>";
        "Rr" = lib.mkDefault ":reply<Enter>";
        "Rq" = lib.mkDefault ":reply -q<Enter>";
        "c" = lib.mkDefault ":cf<space>";
        "$" = lib.mkDefault ":term<space>";
        "!" = lib.mkDefault ":term<space>";
        "|" = lib.mkDefault ":pipe<space>";
        "/" = lib.mkDefault ":search<space>";
        "\\" = lib.mkDefault ":filter<space>";
        "n" = lib.mkDefault ":next-result<Enter>";
        "N" = lib.mkDefault ":prev-result<Enter>";
        "<Esc>" = lib.mkDefault ":clear<Enter>";
        "s" = lib.mkDefault ":split<Enter>";
        "S" = lib.mkDefault ":vsplit<Enter>";
        "pl" = lib.mkDefault ":patch list<Enter>";
        "pa" = lib.mkDefault ":patch apply <Tab>";
        "pd" = lib.mkDefault ":patch drop <Tab>";
        "pb" = lib.mkDefault ":patch rebase<Enter>";
        "pt" = lib.mkDefault ":patch term<Enter>";
        "ps" = lib.mkDefault ":patch switch <Tab>";
      };

      "messages:folder=Drafts" = {
        "<Enter>" = lib.mkDefault ":recall<Enter>";
      };

      view = {
        "/" = lib.mkDefault ":toggle-key-passthrough<Enter>/";
        "q" = lib.mkDefault ":close<Enter>";
        "O" = lib.mkDefault ":open<Enter>";
        "o" = lib.mkDefault ":open<Enter>";
        "S" = lib.mkDefault ":save<space>";
        "|" = lib.mkDefault ":pipe<space>";
        "D" = lib.mkDefault ":delete<Enter>";
        "A" = lib.mkDefault ":archive flat<Enter>";
        "<C-y>" = lib.mkDefault ":copy-link <space>";
        "<C-l>" = lib.mkDefault ":open-link <space>";
        "f" = lib.mkDefault ":forward<Enter>";
        "rr" = lib.mkDefault ":reply -a<Enter>";
        "rq" = lib.mkDefault ":reply -aq<Enter>";
        "Rr" = lib.mkDefault ":reply<Enter>";
        "Rq" = lib.mkDefault ":reply -q<Enter>";
        "H" = lib.mkDefault ":toggle-headers<Enter>";
        "<C-k>" = lib.mkDefault ":prev-part<Enter>";
        "<C-Up>" = lib.mkDefault ":prev-part<Enter>";
        "<C-j>" = lib.mkDefault ":next-part<Enter>";
        "<C-Down>" = lib.mkDefault ":next-part<Enter>";
        "J" = lib.mkDefault ":next<Enter>";
        "<C-Right>" = lib.mkDefault ":next<Enter>";
        "K" = lib.mkDefault ":prev<Enter>";
        "<C-Left>" = lib.mkDefault ":prev<Enter>";
      };

      "view::passthrough" = {
        "$noinherit" = lib.mkDefault "true";
        "$ex" = lib.mkDefault "<C-x>";
        "<Esc>" = lib.mkDefault ":toggle-key-passthrough<Enter>";
      };

      compose = {
        "$noinherit" = lib.mkDefault "true";
        "$ex" = lib.mkDefault "<C-x>";
        "$complete" = lib.mkDefault "<C-o>";
        "<C-k>" = lib.mkDefault ":prev-field<Enter>";
        "<C-Up>" = lib.mkDefault ":prev-field<Enter>";
        "<C-j>" = lib.mkDefault ":next-field<Enter>";
        "<C-Down>" = lib.mkDefault ":next-field<Enter>";
        "<A-p>" = lib.mkDefault ":switch-account -p<Enter>";
        "<C-Left>" = lib.mkDefault ":switch-account -p<Enter>";
        "<A-n>" = lib.mkDefault ":switch-account -n<Enter>";
        "<C-Right>" = lib.mkDefault ":switch-account -n<Enter>";
        "<tab>" = lib.mkDefault ":next-field<Enter>";
        "<backtab>" = lib.mkDefault ":prev-field<Enter>";
        "<C-p>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-PgUp>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-n>" = lib.mkDefault ":next-tab<Enter>";
        "<C-PgDn>" = lib.mkDefault ":next-tab<Enter>";
      };

      "compose::editor" = {
        "$noinherit" = lib.mkDefault "true";
        "$ex" = lib.mkDefault "<C-x>";
        "<C-k>" = lib.mkDefault ":prev-field<Enter>";
        "<C-Up>" = lib.mkDefault ":prev-field<Enter>";
        "<C-j>" = lib.mkDefault ":next-field<Enter>";
        "<C-Down>" = lib.mkDefault ":next-field<Enter>";
        "<C-p>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-PgUp>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-n>" = lib.mkDefault ":next-tab<Enter>";
        "<C-PgDn>" = lib.mkDefault ":next-tab<Enter>";
      };

      "compose::review" = {
        "y" = lib.mkDefault ":send<Enter> # Send";
        "n" = lib.mkDefault ":abort<Enter> # Abort (discard message, no confirmation)";
        "s" = lib.mkDefault ":sign<Enter> # Toggle signing";
        "x" = lib.mkDefault ":encrypt<Enter> # Toggle encryption to all recipients";
        "v" = lib.mkDefault ":preview<Enter> # Preview message";
        "p" = lib.mkDefault ":postpone<Enter> # Postpone";
        "q" = lib.mkDefault ":choose -o d discard abort -o p postpone postpone<Enter> # Abort or postpone";
        "e" = lib.mkDefault ":edit<Enter> # Edit (body and headers)";
        "a" = lib.mkDefault ":attach<space> # Add attachment";
        "d" = lib.mkDefault ":detach<space> # Remove attachment";
      };

      terminal = {
        "$noinherit" = lib.mkDefault "true";
        "$ex" = lib.mkDefault "<C-x>";
        "<C-p>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-n>" = lib.mkDefault ":next-tab<Enter>";
        "<C-PgUp>" = lib.mkDefault ":prev-tab<Enter>";
        "<C-PgDn>" = lib.mkDefault ":next-tab<Enter>";
      };
    };
  };
}
