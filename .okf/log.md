# Update Log

An index of bundle changes, not a narrative. One line each: what changed, the commit it rode in on, and the concept that holds the detail. Rationale lives in the commit message (git keeps it, tied to the diff) or in a [decision](/decisions/index.md) — not here.

## 2026-08-13

* `nixos-options` skill added as the system-level counterpart to `home-manager-options`; its blind spots (hidden renamed aliases, absent third-party modules, search breadth) and its release-upgrade payoff recorded — [workflows/lookup-nixos-option](/workflows/lookup-nixos-option.md)

## 2026-08-12

* Upstream blockers tracked by krank, keyed on the issue URL already in the comment; pull request links normalised to the `/issues/` form by the `rewrite-pr-links` hook — 2574e74 — [workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md)
* The vendored `autoUpgrade` module recorded as deliberate, not debt: upstream needs a checkout on disk, this repo upgrades from a remote flake ref — [decisions/vendored-auto-upgrade](/decisions/vendored-auto-upgrade.md)
* Comment markers collected into one concept — `TODO` / `WORKAROUND` / `HACK` / `UPGRADE`, plus the optional docker-style id that groups a marker spanning several files — [architecture/comment-markers](/architecture/comment-markers.md)
* `nh` adopted as the interactive rebuild front-end — [workflows/rebuild](/workflows/rebuild.md)
* `custom.command-collection` and the `helpers/` mixin category deleted as code rot — [architecture/mixin-pattern](/architecture/mixin-pattern.md)
* CI Nix moved off the DeterminateSystems actions onto `nix-quick-install-action` + `cache-nix-action`; `nix-flake-check` gained a `push: main` run to seed the cache — [decisions/ci-nix-installer](/decisions/ci-nix-installer.md)
* Rejected on a second attempt, a year after the first: Renovate's nix manager — ref-pinned inputs raise no updates, and lock nodes are matched by key rather than resolved through `root.inputs` — 5910dfe — [decisions/renovate-scope](/decisions/renovate-scope.md)
* Update channels returned to the workflow drivers; playbook added to the workflows index — 5910dfe — [workflows/dependency-updates](/workflows/dependency-updates.md)
* CI signing moved off the personal GPG key onto a GitHub App token; `GPG_PRIVATE_KEY`, `GPG_PASSPHRASE` and `PAT` retired — [decisions/ci-identity](/decisions/ci-identity.md)
* Shared update skeleton extracted to `.github/composites/update-pr` — [workflows/dependency-updates](/workflows/dependency-updates.md)

## 2026-08-10

* HDR on DP-2, on demand rather than always on: `bitdepth = 10` — 56a9bdb — [hosts/HAL9000](/hosts/HAL9000.md)
* `hyprctl eval` replaces the nonexistent `hyprctl keyword` under the lua config manager — 56a9bdb — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
* YouTube PWA exempted from the global window translucency — 509d5de — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
* New concept: the `configType = "lua"` settings shape, and that rule keys are validated at runtime rather than build time — 509d5de — [architecture/hyprland-lua-config](/architecture/hyprland-lua-config.md)
* Rejected: a hyprland MCP server (would serve live upstream, not this flake's daily-moving pin) and a pinned `hypr-rules` lookup tool (2 window-rule commits in 12 months — does not amortize)

## 2026-07-29

* `users/joker9944/nixos` made server-safe; desktop-coupled extras gated per owning mixin — 750677b — [architecture/entry-points](/architecture/entry-points.md)
* Change-narrative and forward-looking plans stripped from the concept files — fd68ec6
* Bundle migrated to OKF v0.2 — f825cac
* Profiles added as a role layer above mixins; hosts reduced to deltas — 11c15dd — [architecture/profiles](/architecture/profiles.md), [decisions/host-profiles](/decisions/host-profiles.md)
* Mixins returned to binary `enable`; disko dissolved into `custom.lib.disko.mkDiskoLayout`, boot split into `boot/loader/*` with a mutual-exclusion assertion — 2b2be7e — [architecture/mixin-pattern](/architecture/mixin-pattern.md), [decisions/enable-flag-mixins](/decisions/enable-flag-mixins.md)
* Mixin files renamed to kebab-case matching their camelCase options — [architecture/module-layout](/architecture/module-layout.md)
* `lib/` doc-string convention (RFC 145) recorded — eb13256 — [architecture/custom-lib](/architecture/custom-lib.md)

## 2026-07-27

* cspell dropped from the git hook entirely; the dictionaries submodule replaced by a plain clone — cbb2300 — [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md)

## 2026-07-24

* regreet's hyprland config ported from hyprlang to lua — 22f3895
* New workflow: `UPGRADE(<release>)` markers for deferred release work — 613649b — [workflows/release-upgrade](/workflows/release-upgrade.md)
* Anti-pattern recorded: look for an upstream home-manager module before hand-rolling a plugin's config generation — 157cf55 — [workflows/add-mixin](/workflows/add-mixin.md)

## 2026-07-23

* Option lookup became a nix factory (`mkOptionsTool`) baking `options.json` into `hm-options` / `nixos-options` binaries — 7f5c2c7 — [architecture/packages](/architecture/packages.md)

## 2026-07-22

* `hosts/mixins/` converted to `mkMixinModule` sugar; `lib/mkMixinsModule.nix` deleted — 6fad878 — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-20

* `mkMixinModule` / `mkMixinsModule` added, removing the per-leaf `mkEnableOption` + `mkIf` boilerplate — d3da692 — [architecture/mixin-pattern](/architecture/mixin-pattern.md)

## 2026-07-19

* New concept: the folder and `files/` conventions for every module in the repo, not just mixins — fb1236b — [architecture/module-layout](/architecture/module-layout.md)

## 2026-07-17

* Bundle bootstrapped: overview, architecture, hosts, workflows, decisions — 2ba92ea
* First trimming pass across every concept; release policy extracted from the overview into a decision — 2ba92ea — [decisions/release-policy](/decisions/release-policy.md)
