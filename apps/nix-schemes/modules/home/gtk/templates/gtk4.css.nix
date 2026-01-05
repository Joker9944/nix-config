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

  @define-color secondary_sidebar_bg_color ${palette.base00.hex}; /* background */
  @define-color secondary_sidebar_fg_color @view_fg_color;
  @define-color secondary_sidebar_backdrop_color @view_bg_color;
  @define-color secondary_sidebar_shade_color rgba(0, 0, 0, 0.25);
  @define-color secondary_sidebar_border_color rgba(0, 0, 0, 0.36);

  @define-color destructive_bg_color ${palette.base08.hex}; /* red */

  @define-color success_bg_color ${palette.base0B.hex}; /* green */
  @define-color warning_bg_color ${palette.base09.hex}; /* yellow */
  @define-color error_bg_color ${palette.base08.hex}; /* red */
  :root {
    --accent-blue: ${accents.blue.hex};
    --accent-teal: ${accents.teal.hex};
    --accent-green: ${accents.green.hex};
    --accent-yellow: ${accents.yellow.hex};
    --accent-orange: ${accents.orange.hex};
    --accent-red: ${accents.red.hex};
    --accent-pink: ${accents.pink.hex};
    --accent-purple: ${accents.purple.hex};
    --accent-slate: ${accents.slate.hex};
    --accent-bg-color: @accent_bg_color;
    --accent-fg-color: @accent_fg_color;
    --window-bg-color: @window_bg_color;
    --window-fg-color: @window_fg_color;
    --view-bg-color: @view_bg_color;
    --view-fg-color: @view_fg_color;
    --headerbar-bg-color: @headerbar_bg_color;
    --headerbar-fg-color: @headerbar_fg_color;
    --headerbar-backdrop-color: @headerbar_backdrop_color;
    --sidebar-bg-color: @sidebar_bg_color;
    --sidebar-fg-color: @sidebar_fg_color;
    --sidebar-backdrop-color: @sidebar_backdrop_color;
    --sidebar-shade-color: @sidebar_shade_color;
    --sidebar-border-color: @sidebar_border_color;
    --secondary-sidebar-bg-color: @secondary_sidebar_bg_color;
    --secondary-sidebar-fg-color: @secondary_sidebar_fg_color;
    --secondary-sidebar-backdrop-color: @secondary_sidebar_backdrop_color;
    --secondary-sidebar-shade-color: @secondary_sidebar_shade_color;
    --secondary-sidebar-border-color: @secondary_sidebar_border_color;
    --card-bg-color: @card_bg_color;
    --card-fg-color: @card_fg_color;
    --dialog-bg-color: @dialog_bg_color;
    --dialog-fg-color: @dialog_fg_color;
    --popover-bg-color: @popover_bg_color;
    --popover-fg-color: @popover_fg_color;
    --destructive-bg-color: @destructive_bg_color;
    --success-bg-color: @success_bg_color;
    --warning-bg-color: @warning_bg_color;
    --error-bg-color: @error_bg_color;
  }
''
