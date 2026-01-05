cfg: accents:
let
  inherit (cfg.scheme) palette;
in
''
  @define-color window_bg_color ${palette.base00.hex}; /* background */
  @define-color window_fg_color ${palette.base05.hex}; /* foreground */

  @define-color view_bg_color ${palette.base00.hex}; /* background */
  @define-color view_fg_color ${palette.base05.hex}; /* foreground */

  @define-color accent_bg_color ${accents.${cfg.accent}.hex};
  @define-color accent_fg_color ${palette.base05.hex}; /* foreground */

  @define-color headerbar_bg_color ${palette.base01.hex}; /* light background */
  @define-color headerbar_fg_color ${palette.base05.hex}; /* foreground */
  @define-color headerbar_backdrop_color @window_bg_color;

  @define-color popover_bg_color ${palette.base00.hex}; /* background */
  @define-color popover_fg_color ${palette.base05.hex}; /* foreground */

  @define-color dialog_bg_color ${palette.base01.hex}; /* light background */
  @define-color dialog_fg_color @view_fg_color;

  @define-color card_bg_color ${palette.base01.hex}; /* light background */
  @define-color card_fg_color @view_fg_color;

  @define-color sidebar_bg_color ${palette.base00.hex}; /* background */
  @define-color sidebar_fg_color ${palette.base05.hex}; /* foreground */
  @define-color sidebar_backdrop_color @window_bg_color;
  @define-color sidebar_shade_color rgba(0,0,0,0.25);
  @define-color sidebar_border_color rgba(0, 0, 0, 0.36);

  @define-color destructive_bg_color ${palette.base08.hex}; /* red */

  @define-color success_bg_color ${palette.base0B.hex}; /* green */
  @define-color warning_bg_color ${palette.base09.hex}; /* yellow */
  @define-color error_bg_color ${palette.base08.hex}; /* red */
''
