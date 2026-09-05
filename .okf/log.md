# Update Log

An index of bundle changes, not a narrative. One line each: what changed and the concept that holds the detail, in the form `CLAUDE.md` rule 3 sets. Rationale lives in the commit message, tied to the diff, or in a [decision](/decisions/index.md) — not here.

## 2026-09-05

- The k3s sops file moved into the mixin; per-secret `sopsFile`, since `defaultSopsFile` is host-global — [workflows/secrets](/workflows/secrets.md)
- Sops payloads go in `secrets/`, not `files/`, and only inside a leaf module folder — [architecture/module-layout](/architecture/module-layout.md)
- `conform` gates commit messages at the commit-msg stage; types and scopes live in `.conform.yaml` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)
- A `pkgs/` subdir also holds a single package whose script lives under `files/`, not only input-hungry groups — [architecture/packages](/architecture/packages.md)
- The `server` profile and the four headless nyx-cluster hosts; cluster roles are mixins, not a second profile — [architecture/profiles](/architecture/profiles.md), [hosts/nyx-cluster](/hosts/nyx-cluster.md)
- System-level sops decrypted at activation via each host's SSH host key — [workflows/secrets](/workflows/secrets.md)
- The `server-longhorn-v1` disko template and `mkDiskoLayout`'s `longhorn` size default — [hosts/nyx-cluster](/hosts/nyx-cluster.md)

## 2026-09-04

- The module trees live under `modules/{home,nixos}/`; flake outputs are flat `mkModules` keys — [architecture/entry-points](/architecture/entry-points.md), [architecture/auto-discovery](/architecture/auto-discovery.md)
- The theme's per-tree halves sit in one auto-discovered `compat.nix` behind `mkClassModule` — [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- `mixins.programs.steam.resolution` is the second non-enable mixin surface beside hyprland's — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- The option-lookup workflows are gone; the two skills' `SKILL.md` files are the sole authority — [architecture/packages](/architecture/packages.md)

## 2026-09-01

- `schemes.spicetify` recolours Spotify via spicetify-nix's `customColorScheme` — [decisions/scheme-model](/decisions/scheme-model.md)
- `mkVariantModules` generates one scheme module per browser and editor, each with its own `enable` — [architecture/custom-lib](/architecture/custom-lib.md), [decisions/scheme-model](/decisions/scheme-model.md)
- An installed Firefox theme never updates: sideload change detection is mtime-or-path, Nix pins both — [reference/firefox-theming](/reference/firefox-theming.md)
- `schemes.librewolf` renders through FirefoxColor's `storage.local`, not a static theme xpi — [reference/firefox-theming](/reference/firefox-theming.md), [decisions/scheme-model](/decisions/scheme-model.md)
- `schemes.vscode` generates a theme extension; slots follow tinted-vscode's `base24.mustache` — [reference/base24](/reference/base24.md), [decisions/scheme-model](/decisions/scheme-model.md)
- `inputs.tinted-vscode` stays an input, not vendored; a test pins the theme's delta against it — [decisions/vendored-schemes](/decisions/vendored-schemes.md)

## 2026-08-31

- Modules take `flake`/`inputs`/`libUtil`/`libMath` as `importApply` args; only `osConfig` is special — [architecture/entry-points](/architecture/entry-points.md)

## 2026-08-28

- The theme is one dual-class `modules/theme/` dispatching on `_class`; `modules/global/` is gone — [architecture/module-layout](/architecture/module-layout.md), [decisions/dual-class-modules](/decisions/dual-class-modules.md)
- A theme is picked by `custom.themes.<name>.enable` via a local `mkThemeModule`, outside `mixins.` — [architecture/module-layout](/architecture/module-layout.md), [architecture/mixin-pattern](/architecture/mixin-pattern.md)
- `mkClassModule` selects by `_class`; a missing class key is a no-op, an unknown key throws — [architecture/custom-lib](/architecture/custom-lib.md)
- corrected: nix-schemes' shared modules arrive via `<class>Modules.default` imports in the glue — [architecture/module-layout](/architecture/module-layout.md)
- `meta.slug`: vendored for a tinted source, `libUtil.strings.slugify` of the name for a custom one — [decisions/scheme-model](/decisions/scheme-model.md)
- `overrides.palette` applies before the upcast, so a derived slot follows the slot it comes from — [decisions/scheme-model](/decisions/scheme-model.md)

## 2026-08-24

- The scheme is a total derived model; the transformer API and `requireKey` are gone — [decisions/scheme-model](/decisions/scheme-model.md)
- Per-scheme deviation is `schemes.overrides.<view>.<path>`, a palette slot name or a hex string — [decisions/scheme-model](/decisions/scheme-model.md)
- Sources: `schemes.source.tinted`/`.custom`; `generateScheme` yields a source, `mkScheme` the scheme — [architecture/custom-lib](/architecture/custom-lib.md)
- base16 upcasts to base24 unconditionally, so no consumer branches on `meta.system` — [reference/base24](/reference/base24.md)
- `named`, `status`, `ansi` are always-present views; colour words carry `normal`/`bright` — [reference/base24](/reference/base24.md)
- `schemes.accent` carries the accent; `custom.theme.gtk.accent` selects GNOME's nine only — [architecture/module-layout](/architecture/module-layout.md)
- Cursor slots are declared options with derived defaults; `custom.theme.altColor` is gone — [reference/cursor-theming](/reference/cursor-theming.md)
- `toHsl`/`fromHsl`/`rotateHue` in the color lib; `accentAlt` is the accent turned −120° — [reference/cursor-theming](/reference/cursor-theming.md)
- corrected: on a dark scheme `fill` is `base00` and `outline` is `base06`, not the reverse — [reference/cursor-theming](/reference/cursor-theming.md)

## 2026-08-23

- Cursor themes compile Breeze SVGs to XCursor/`cursors_scalable`/hyprcursor — no recolouring hook — [reference/cursor-theming](/reference/cursor-theming.md)
- `schemes.cursors` owns the cursor theme; `name` is derived rather than configured — [reference/cursor-theming](/reference/cursor-theming.md)
- Python lints with flake8 + ruff-format at 79 columns; sandboxed flake8 needs no `flakeIgnore` — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)
- A python app takes `writePython3Bin` with `makeWrapperArgs` and carries no shebang — [architecture/module-layout](/architecture/module-layout.md)
- The `breeze` input pins a tag; its vendored templates are regenerated by hand — [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-22

- `schemes.icons` exposes the recoloured pack read-only to both trees — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkIconTheme` recolours Plasma `ColorScheme-*` stylesheets; GTK recolours only by filename suffix — [reference/gtk-theming](/reference/gtk-theming.md)
- corrected: a nix-schemes library module *may* read a transformer-added key, through `requireKey` — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-21

- `exclude` keeps a value sibling like `tidy/timer.nix` out of auto-discovery — [architecture/auto-discovery](/architecture/auto-discovery.md)
- IFD is disabled machine-wide and in the CI `nix_conf`; recovery is per-invocation `--option` — [decisions/no-ifd](/decisions/no-ifd.md)
- `pkgs-unstable` is the second escape hatch from the stable-only pin — [decisions/release-policy](/decisions/release-policy.md)
- Desktop-file contents are read by derivations, never at evaluation; `[Added Associations]` is gone — [decisions/desktop-files-at-build-time](/decisions/desktop-files-at-build-time.md)
- `requireDesktopFile` checks entries at build time; `lookupDesktopFiles` reads `desktopItems` — [architecture/custom-lib](/architecture/custom-lib.md)
- Shell bodies over 400 chars move to `files/<name>.sh`; nix values pass as env via `runtimeEnv` — [architecture/module-layout](/architecture/module-layout.md)
- `git` is taken from the ambient PATH rather than declared in `runtimeInputs`, except under systemd — [architecture/module-layout](/architecture/module-layout.md)

## 2026-08-20

- `generateScheme` reads a vendored Nix tree instead of parsing YAML; `fromYaml` and its IFD are gone — [decisions/vendored-schemes](/decisions/vendored-schemes.md)
- Vendored schemes refresh via monthly `nix-schemes-update.yaml`; `spec-0.11` is a branch, not a tag — [workflows/dependency-updates](/workflows/dependency-updates.md)
- `flake.schemes.<system>.<slug>` is the scheme itself; `generateScheme` lives in `lib/` — [architecture/custom-lib](/architecture/custom-lib.md)
- Colour primitives and WCAG metrics live under `libSchemes.color` — [architecture/custom-lib](/architecture/custom-lib.md)
- The image-based scheme source (`schemes.source.picture`, `base24-gen`) is gone — [architecture/custom-lib](/architecture/custom-lib.md)
- GTK CSS: `_defaults.scss` takes palette literals; `settings/_colors.scss` toolkit-branched forms — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkGtkThemeCss` consumers `@import` the store path; per-variant entries, multi-root `SASS_PATH` — [reference/gtk-theming](/reference/gtk-theming.md)

## 2026-08-19

- adw-gtk3 is mandatory — stock stylesheets are flat-compiled; GTK4 applies it via the user stylesheet — [reference/gtk-theming](/reference/gtk-theming.md)
- `mkGtkThemeCss` compiles SCSS: Nix resolves colours, SCSS owns structure — [reference/gtk-theming](/reference/gtk-theming.md)
- `color.relativeLuminance` / `color.contrastRatio` added; GTK foreground picks use WCAG contrast — [reference/base24](/reference/base24.md)
- `home.file` aborts on a pre-existing unmanaged target without `backupFileExtension` — [workflows/rebuild](/workflows/rebuild.md)
- The `nix-schemes` sub-flake exports modules by hand; a new one needs registering twice — [architecture/auto-discovery](/architecture/auto-discovery.md)
- vicinae wraps its own launches in `uwsm-app`; its `Terminal=true` path needs `xdg-terminals.list` — [architecture/uwsm-session](/architecture/uwsm-session.md)
- The five ANSI assignments base16 and base24 disagree on, and which each consumer follows — [reference/base24](/reference/base24.md)
- Scheme non-standard keys come from `schemes.transformers`, read with `libSchemes.requireKey` — [architecture/custom-lib](/architecture/custom-lib.md)
- kitty home module added; follows base24 ANSI via the scheme's `ansi` attribute — [reference/base24](/reference/base24.md)
- corrected: base24 spec source is tinted-theming; the fork's four divergent ANSI slots were wrong — [reference/base24](/reference/base24.md)
- `warning` is `base09` (not spec's `base0F`) as a deliberate deviation; `success` added — [reference/base24](/reference/base24.md)

## 2026-08-17

- Unit switched to `X-Restart-Triggers`; the reload form silently no-ops without `ExecReload` — [apps/yas](/apps/yas.md)
- Popup timers only for `expireTimeout <= 0`; the daemon resolves the rest — [apps/yas](/apps/yas.md)
- No destructuring live GObject properties; explicit `onCleanup` destroy; `GError` calls throw — [apps/yas](/apps/yas.md)
- `npm run types` produces `@girs/` and `tsconfig.json`, which is untracked and loses `lib` on regen — [workflows/develop-yas](/workflows/develop-yas.md)
- A new source file is invisible to `nix build` until it is `git add`ed — [workflows/develop-yas](/workflows/develop-yas.md)
- `notify-send` corpus covering both body branches and visual resolution — [workflows/develop-yas](/workflows/develop-yas.md)
- The home module installs the `astal-notifd` CLI, the only way to reach do-not-disturb — [apps/yas](/apps/yas.md)

## 2026-08-16

- `apps/yas` documented: runtime shape, lazy-accessor convention, styling and nix integration — [apps/yas](/apps/yas.md), [apps/](/apps/index.md)
- yas dev loop: ags CLI scripts, `@girs` regeneration; a prettier hook cannot cover `apps/yas` — [workflows/develop-yas](/workflows/develop-yas.md)
- wintermute's home-manager deltas recorded (`wayvnc`, yas battery) — [hosts/wintermute](/hosts/wintermute.md)
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

- `nixos-options` skill added as the system-level counterpart to `hm-options` — [architecture/packages](/architecture/packages.md)

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
- The `configType = "lua"` shape; YouTube PWA exempted from translucency — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
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
