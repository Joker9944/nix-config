# Update Log

An index of bundle changes, not a narrative. One line each: what changed and the concept that holds the detail, in the form `CLAUDE.md` rule 3 sets. Rationale lives in the commit message, tied to the diff, or in a [decision](/decisions/index.md) — not here.

## 2026-09-01

- `mkVariantModules` generates one scheme module per browser and per editor, each with its own `enable` — [architecture/custom-lib](/architecture/custom-lib.md), [decisions/scheme-model](/decisions/scheme-model.md)

- New reference: an installed Firefox theme never updates — sideload change detection is mtime-or-path and Nix pins both — [reference/firefox-theming](/reference/firefox-theming.md)
- `schemes.librewolf` renders through the FirefoxColor extension's `storage.local` instead of a static theme xpi — [reference/firefox-theming](/reference/firefox-theming.md), [decisions/scheme-model](/decisions/scheme-model.md)
- `schemes.vscode` generates a VS Code theme extension from the scheme; the vscodium mixin dropped its pinned Dracula theme — [reference/base24](/reference/base24.md), [decisions/scheme-model](/decisions/scheme-model.md)
- The vscode theme's slot assignments follow tinted-vscode's `base24.mustache` rather than the editor-role column — [reference/base24](/reference/base24.md)
- `inputs.tinted-vscode` is read from the input rather than vendored, and a test pins the theme's delta against it — [decisions/vendored-schemes](/decisions/vendored-schemes.md)

## 2026-08-31

- `specialArgs` dissolved: modules take `flake`/`inputs`/`libUtil`/`libMath` as static `importApply` args, leaving `osConfig` the only `extraSpecialArg` — [architecture/entry-points](/architecture/entry-points.md)

## 2026-08-28
- The theme is one directory, `modules/theme/`, dispatching to `nixos.nix` / `home.nix` on `_class`; `modules/global/` is gone — [architecture/module-layout](/architecture/module-layout.md), [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- A theme is picked by `custom.themes.<name>.enable`, declared by a local `mkThemeModule`; themes left the `mixins.` namespace — [architecture/module-layout](/architecture/module-layout.md), [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- `exclude` also keeps a class-branch file out of auto-discovery, not just a value sibling — [architecture/auto-discovery](/architecture/auto-discovery.md)
- `mkClassModule` selects a module by the evaluation's `_class`; a class with no key is a no-op and a key naming no class throws — [architecture/custom-lib](/architecture/custom-lib.md)
- New decision: a dual-class module is a class-agnostic core plus one glue module per tree; `_class` selects at eval time and the dendritic pattern is not adopted — [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- corrected: nix-schemes' shared modules are imported by the per-tree glue via `<class>Modules.default`, not by `modules/global/theme/` — [architecture/module-layout](/architecture/module-layout.md)
- `meta.slug` is the vendored slug for a tinted source and `libUtil.strings.slugify` of the name for a custom one — [decisions/scheme-model](/decisions/scheme-model.md)
- `overrides.palette` applies before the upcast, so a derived slot follows the slot it comes from — [decisions/scheme-model](/decisions/scheme-model.md)

## 2026-08-24
- New decision: the scheme is a total derived model; `schemes.transformers`, `scheme.transform`, `accentTransformer` and `requireKey` are gone — [decisions/scheme-model](/decisions/scheme-model.md)
- Per-scheme deviation is `schemes.overrides.<view>.<path>`, a palette slot name or a hex string — [decisions/scheme-model](/decisions/scheme-model.md)
- Sources are `schemes.source.tinted` / `.custom`; `generateScheme` returns a source, `mkScheme` builds the scheme — [architecture/custom-lib](/architecture/custom-lib.md)
- base16 upcasts to base24 unconditionally, so no consumer branches on `meta.system` — [reference/base24](/reference/base24.md)
- `named`, `status` and `ansi` are views under `lib/views/`, always present; the colour words carry `normal`/`bright` — [reference/base24](/reference/base24.md)
- `schemes.accent` carries the accent; `custom.theme.gtk.accent` is the GNOME selector only, and `uniformAccents` collapses the nine — [architecture/module-layout](/architecture/module-layout.md)
- Cursor slots are declared options with derived defaults, replacing the untyped `slots` attrset; `custom.theme.altColor` is gone — [reference/cursor-theming](/reference/cursor-theming.md)
- `toHsl`, `fromHsl` and `rotateHue` join the color lib; `accentAlt` is the accent turned −120° rather than a fixed palette slot — [reference/cursor-theming](/reference/cursor-theming.md)
- `custom.theme.altColor` sets a second accent theme-wide, reaching the scheme only when configured — [reference/cursor-theming](/reference/cursor-theming.md)
- corrected: on a dark scheme `fill` is `base00` and `outline` is `base06`, not the reverse — [reference/cursor-theming](/reference/cursor-theming.md)

## 2026-08-23
- New concept: cursor themes are compiled from Breeze's SVGs into XCursor, `cursors_scalable` and hyprcursor, because the format has no recolouring hook — [reference/cursor-theming](/reference/cursor-theming.md)
- `schemes.cursors` replaces `custom.theme.cursor`, which is gone; `name` is derived rather than configured — [reference/cursor-theming](/reference/cursor-theming.md)
- Python linting moved from `ruff` to `flake8` with `ruff-format` at 79 columns, so nixpkgs' sandboxed flake8 needs no `flakeIgnore` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)
- A python app takes `writers.writePython3Bin` with `makeWrapperArgs`, not a shell wrapper, and carries no shebang — [architecture/module-layout](/architecture/module-layout.md)
- The `breeze` input is pinned to a tag and its vendored templates are regenerated by hand, unlike the schemes tree — [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-22
- `schemes.icons` exposes the recoloured pack as a readOnly option to both trees; `custom.theme.icons` dropped, since the theme module configures `schemes.*` rather than re-exporting it — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkIconTheme` recolours a pack's Plasma `ColorScheme-*` stylesheets, since GTK recolours only by filename suffix — [reference/gtk-theming](/reference/gtk-theming.md)
- corrected: a nix-schemes library module *may* read a transformer-added key, through `requireKey` — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-21
- `exclude` keeps a value sibling out of an auto-discovered module directory, as `modules/home/tidy/` does with `timer.nix` — [architecture/auto-discovery](/architecture/auto-discovery.md)
- IFD is disabled machine-wide and in the CI `nix_conf`, and how to get past it when a third-party flake needs it — [decisions/no-ifd](/decisions/no-ifd.md)
- `pkgs-unstable` named as the second escape hatch from the stable-only pin, and what it costs when a package changes config schema mid-cycle — [decisions/release-policy](/decisions/release-policy.md)
- Desktop-file contents are read by derivations, never during evaluation; `[Added Associations]` is gone — [decisions/desktop-files-at-build-time](/decisions/desktop-files-at-build-time.md)
- `requireDesktopFile` takes `pkgs` and checks an undeclared entry at build time; `lookupDesktopFiles` reads `desktopItems` only — [architecture/custom-lib](/architecture/custom-lib.md)
- Shell bodies longer than 400 characters move to `files/<name>.sh`, with nix values passed as environment via `runtimeEnv` — [architecture/module-layout](/architecture/module-layout.md)
- `git` is taken from the ambient PATH rather than declared in `runtimeInputs`, except under systemd — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-20
- `generateScheme` reads a vendored Nix tree instead of parsing YAML; `fromYaml` and its IFD are gone — [decisions/vendored-schemes](/decisions/vendored-schemes.md)
- The vendored schemes are refreshed by a monthly `nix-schemes-update.yaml`, not checked at eval time; `spec-0.11` is a branch, not a tag — [workflows/dependency-updates](/workflows/dependency-updates.md)
- `flake.schemes.<schemeSystem>.<schemeSlug>` is the scheme itself; the `convert pkgs` wrapper is gone and `generateScheme` moved to `lib/` — [architecture/custom-lib](/architecture/custom-lib.md)
- Colour primitives and WCAG metrics moved under `libSchemes.color`; only `requireKey`, `types` and `init`'s members sit at the root — [architecture/custom-lib](/architecture/custom-lib.md)
- The image-based scheme source (`schemes.source.picture`, `base24-gen`) is gone — [architecture/custom-lib](/architecture/custom-lib.md)
- GTK CSS routing split: `_defaults.scss` reads palette literals only, `settings/_colors.scss` holds toolkit-branched reference forms for widget rules — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkGtkThemeCss` drops IFD (consumers `@import` the store path), gains static per-variant entry points and multi-root `SASS_PATH` — [reference/gtk-theming](/reference/gtk-theming.md)

## 2026-08-19

- New concept: adw-gtk3 is mandatory because the stock stylesheets are flat-compiled; `gtk.gtk4.theme` applies it through the user stylesheet — [reference/gtk-theming](/reference/gtk-theming.md)
- GTK CSS compiled from SCSS by `mkGtkThemeCss`; Nix resolves colours, SCSS owns structure, opaque-literal defaults are the override surface — [reference/gtk-theming](/reference/gtk-theming.md)
- `color.relativeLuminance` / `color.contrastRatio` added; GTK foreground picks use WCAG contrast — [reference/base24](/reference/base24.md)
- `home.file` aborts on a pre-existing unmanaged target and no `backupFileExtension` is set; `programs.claude-code.settings` hits it — [workflows/rebuild](/workflows/rebuild.md)
- The `nix-schemes` sub-flake exports modules by hand; a new one needs registering twice — [architecture/auto-discovery](/architecture/auto-discovery.md)
- vicinae wraps its own launches in `uwsm-app`; its `Terminal=true` path needs `xdg-terminals.list` — [architecture/uwsm-session](/architecture/uwsm-session.md)
- base24 slots documented: the five ANSI assignments base16 and base24 disagree on, and which each consumer follows — [reference/base24](/reference/base24.md)
- Scheme non-standard keys come only from `schemes.transformers` and are read with `libSchemes.requireKey` — [architecture/custom-lib](/architecture/custom-lib.md)
- kitty home module added; follows base24 ANSI via the scheme's `ansi` attribute — [reference/base24](/reference/base24.md)
- base24 spec source corrected to tinted-theming; the fork's four divergent ANSI slots were wrong in `ansi.nix`, `named.nix` and `mkAccentsFromPalette.nix` — [reference/base24](/reference/base24.md)
- Status colours documented as a deliberate deviation: `warning` is `base09`, not the spec's `base0F`; `success` added — [reference/base24](/reference/base24.md)

## 2026-08-17

- Unit switched to `X-Restart-Triggers`; the reload form silently no-ops without `ExecReload` — [apps/yas](/apps/yas.md)
- Popup timers only for `expireTimeout <= 0`; the daemon resolves the rest — [apps/yas](/apps/yas.md)

- Live GObject properties must not be destructured; windows need an explicit `onCleanup` destroy; `GError` calls throw instead of returning a flag — [apps/yas](/apps/yas.md)
- `npm run types` identified as what produces `@girs/` and the `node_modules` links; type-checking recipe added — [workflows/develop-yas](/workflows/develop-yas.md)
- `tsconfig.json` untracked, with the `lib` it loses on regeneration recorded — [workflows/develop-yas](/workflows/develop-yas.md)
- A new source file is invisible to `nix build` until it is `git add`ed — [workflows/develop-yas](/workflows/develop-yas.md)
- `notify-send` corpus covering both body branches and visual resolution — [workflows/develop-yas](/workflows/develop-yas.md)
- The home module installs the `astal-notifd` CLI, the only way to reach do-not-disturb — [apps/yas](/apps/yas.md)

## 2026-08-16

- `apps/yas` documented: runtime shape, lazy-accessor convention, styling and nix integration — [apps/yas](/apps/yas.md), [apps/](/apps/index.md)
- yas dev loop recorded: ags CLI scripts, `@girs` regeneration, prettier outside the hook set — [workflows/develop-yas](/workflows/develop-yas.md)
- wintermute's home-manager deltas recorded (`wayvnc`, yas battery) — [hosts/wintermute](/hosts/wintermute.md)
- Why a `prettier` hook cannot cover `apps/yas` recorded, after trying one — [workflows/develop-yas](/workflows/develop-yas.md)
- Log rewritten to rule 3's form: one line per change, no commit SHAs
- Hyprland is pinned to an upstream tag, not the default branch — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md), [decisions/release-policy](/decisions/release-policy.md)
- Sibling modules are auto-discovered; only `tmux`, `waybar` and `rofi` import siblings explicitly — [architecture/module-layout](/architecture/module-layout.md)
- Theme owns the `monospace` and `emoji` fontconfig generics in the home tree — [architecture/module-layout](/architecture/module-layout.md)
- Themes became a `mixins.theme.<name>` category in `modules/global/`; accent split out — [architecture/mixin-pattern](/architecture/mixin-pattern.md), [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-15

- `lib/` split: general-purpose helpers to the `apps/util-lib` flake as `libUtil` — [decisions/util-lib-split](/decisions/util-lib-split.md), [architecture/custom-lib](/architecture/custom-lib.md)
- `apps/nix-schemes` adopted `libUtil` and the lib conventions — [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-08-14

- Bind- and rofi-launched apps routed through `uwsm-app` for their own systemd unit — [architecture/uwsm-session](/architecture/uwsm-session.md), [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-08-13

- `nixos-options` skill added as the system-level counterpart to `hm-options` — [workflows/lookup-nixos-option](/workflows/lookup-nixos-option.md)

## 2026-08-12

- Upstream blockers tracked by krank; the four comment markers recorded — [workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md), [architecture/comment-markers](/architecture/comment-markers.md)
- The vendored `autoUpgrade` module recorded as deliberate, not debt — [decisions/vendored-auto-upgrade](/decisions/vendored-auto-upgrade.md)
- `nh` adopted as the interactive rebuild front-end — [workflows/rebuild](/workflows/rebuild.md)
- `custom.command-collection` and the `helpers/` mixin category deleted as code rot — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- CI Nix moved to `nix-quick-install-action` + `cache-nix-action` — [decisions/ci-nix-installer](/decisions/ci-nix-installer.md)
- Renovate's nix manager rejected again; update channels returned to the workflows — [decisions/renovate-scope](/decisions/renovate-scope.md), [workflows/dependency-updates](/workflows/dependency-updates.md)
- CI signing moved to a GitHub App token; update skeleton extracted to a composite — [decisions/ci-identity](/decisions/ci-identity.md), [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-10

- HDR on DP-2 on demand via `bitdepth = 10`; `hyprctl eval` replaces the absent `keyword` — [hosts/HAL9000](/hosts/HAL9000.md), [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- New concept: the `configType = "lua"` shape; YouTube PWA exempted from translucency — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
- Rejected: a hyprland MCP server and a pinned `hypr-rules` lookup tool

## 2026-07-29

- `users/joker9944/nixos` made server-safe; desktop extras gated per owning mixin — [architecture/entry-points](/architecture/entry-points.md)
- Bundle migrated to OKF v0.2 and stripped of change-narrative
- Profiles added as a role layer above mixins; hosts reduced to deltas — [architecture/profiles](/architecture/profiles.md), [decisions/host-profiles](/decisions/host-profiles.md)
- Mixins returned to binary `enable`; files renamed to kebab-case matching their options — [architecture/mixin-pattern](/architecture/mixin-pattern.md), [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md), [architecture/module-layout](/architecture/module-layout.md)
- `lib/` doc-string convention (RFC 145) recorded — [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-07-27

- cspell dropped from the git hook; dictionaries submodule replaced by a plain clone — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)

## 2026-07-24

- regreet's hyprland config ported from hyprlang to lua
- New workflow: `UPGRADE(<release>)` markers for deferred release work — [workflows/release-upgrade](/workflows/release-upgrade.md)
- Anti-pattern: look for an upstream home-manager module before hand-rolling config — [workflows/add-mixin](/workflows/add-mixin.md)

## 2026-07-23

- Option lookup became a nix factory baking `options.json` into the query binaries — [architecture/packages](/architecture/packages.md)

## 2026-07-22

- `hosts/mixins/` converted to `mkMixinModule` sugar — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-20

- `mkMixinModule` / `mkMixinsModule` added, removing per-leaf boilerplate — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-19

- New concept: folder and `files/` conventions for every module, not just mixins — [architecture/module-layout](/architecture/module-layout.md)

## 2026-07-17

- Bundle bootstrapped; release policy extracted from the overview — [decisions/release-policy](/decisions/release-policy.md)
