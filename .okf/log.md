# Update Log

An index of bundle changes, not a narrative. One line each: what changed and the concept that holds the detail, in the form `CLAUDE.md` rule 3 sets. Rationale lives in the commit message, tied to the diff, or in a [decision](/decisions/index.md) — not here.

## 2026-08-16

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
