---
type: Architecture Pattern
title: Hyprland lua config surface
description: The hyprland tree emits `hyprland.lua`, not `hyprland.conf`. Documents the `settings` shape and the fact that rule keys are validated at runtime, not build time — so `nix build` proves nothing about a rule's validity.
tags: [architecture, hyprland, home-manager, convention]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-10T18:00:00Z
---

# configType = "lua"

`users/mixins/desktop-environment/hyprland/hyprland/default.nix` sets
`wayland.windowManager.hyprland.configType = "lua"`, so home-manager writes
`$XDG_CONFIG_HOME/hypr/hyprland.lua` instead of `hyprland.conf`. Every attribute under
`settings` becomes an `hl.<name>(…)` call; list values emit one call per element.

This changes the shape of `settings` from the hyprlang form most wiki examples use:

* Hyprland's config *variables* nest under **`settings.config`** (`config.general`,
  `config.decoration`, `config.input`, `config.misc`, …).
* Rules and bindings sit at the **top level** of `settings` — `bind`, `window_rule`,
  `layer_rule`, `on`, `define_submap`.

`custom.lib.mkLuaCall` builds the `_args` multi-argument form; `lib.generators.mkLuaInline`
emits a raw lua expression. See [custom-lib](custom-lib.md).

`window_rule` is a list that merges across every module in the tree —
`hyprland/system.nix`, `gaming.nix`, `terminal/kitty/default.nix` and
`pwas/youtube/default.nix` all contribute independently. Give every rule a `name`: it is
the repo convention, and re-declaring an existing name updates that rule rather than
registering a second one.

Global window translucency comes from `mixins.desktopEnvironment.hyprland.style.opacity`,
which feeds `decoration.active_opacity` / `inactive_opacity` — so *every* window is
translucent by default and exempting one is a per-window rule, not a style change.

# Rule keys are validated at runtime, not at build time

This is the load-bearing fact. Home-manager passes the `window_rule` attrset through to lua
verbatim — it does not know Hyprland's key vocabulary. A misspelled match property or
effect **builds clean, activates clean, and silently does nothing**. The failure surfaces
only in `hyprctl configerrors`.

So `nix build` succeeding is not evidence a rule works. After a `home-manager switch`:

```bash
grep -A6 '<rule-name>' ~/.config/hypr/hyprland.lua    # home-manager wrote it
hyprctl configerrors                                   # Hyprland accepted it (empty = ok)
hyprctl getprop "address:$ADDR" <effect>               # it applied to a live window
```

`$ADDR` comes from `hyprctl clients -j | jq -r '.[] | select(…) | .address'`. There is no
`hyprctl rules`.

# Runtime control is `eval`, not `keyword`

`hyprctl keyword` **does not exist** under the lua config manager — the command is not
registered and returns `unknown request`. Effectively every wiki example and every recalled
snippet reaches for it, so this is the trap: it is not a syntax problem to work around, the
verb is gone. The replacements are `hyprctl eval` / `hyprctl repl`, which evaluate lua
against the live config, and `hyprctl dispatch`, which under lua is a thin wrapper for
`hl.dispatch(…)`.

A live experiment therefore re-issues the same `hl.<name>({…})` call the generated config
emits, and `reload` throws it away:

```bash
hyprctl eval 'hl.monitor({["output"]="DP-2",["mode"]="2560x1440@143.97Hz",["position"]="1920x0",["bitdepth"]=10})'
hyprctl reload   # discard, restore from ~/.config/hypr/hyprland.lua
```

Read the exact call shape out of `~/.config/hypr/hyprland.lua` rather than reconstructing
it — home-manager emits bracketed string keys (`["output"] = …`), and re-declaring a rule
for an output that already has one updates it rather than stacking a second.

Pair this with the runtime-validation fact above: since a wrong key fails silently and a
rebuild proves nothing, `eval` is the short loop for finding out whether Hyprland actually
accepts something, and the nix change is what you write once it does.

One shape trap is stable enough to name: config keys are **snake_case**
(`initial_class`), while `hyprctl clients -j` reports the same fields in **camelCase**
(`initialClass`). Copying a key out of `hyprctl` output into a rule is the easy way to hit
the silent failure above.

# Look the keys up, don't recall them

`flake.nix` pins `hyprland.url = "github:hyprwm/Hyprland"` — the default branch, not a
release (see [decisions/release-policy](/decisions/release-policy.md)). It advances most
days, so any enumeration of match properties, effect names, or their lua value types is
stale on a scale of days and is deliberately **not** reproduced here. Read them out of the
pinned tree instead:

```bash
HYPR=$(nix flake archive --json | jq -r '.inputs.hyprland.path')
grep -rn "MATCH_PROP_STRINGS\|EFFECT_STRINGS\|WINDOW_RULE_EFFECT_DESCS" "$HYPR/src"
```

Those three identifiers are the authoritative lists: match properties, window-rule effect
names, and the effects' lua value types respectively. Grepping identifiers rather than
paths survives upstream moving files — and if a name disappears, the empty result tells you
to go looking rather than letting you trust something stale.

The lua-LSP stub at `<hyprland>/share/hypr/stubs/hl.meta.lua` covers config variables, but
is **not** a usable reference for rule effects: its `HL.WindowRuleSpec` declares only
`name`, `match` and `enabled`, because effect fields are resolved dynamically.

# Related

* [custom-lib](custom-lib.md) — `mkLuaCall`, for the `_args` multi-argument lua form.
* [mixin-pattern](mixin-pattern.md) — the hyprland tree is the one hand-rolled fan-out
  whose namespace carries more than an `enable`.
* [decisions/release-policy](/decisions/release-policy.md) — why hyprland tracks upstream
  while nixpkgs and home-manager are pinned to a release.
* [workflows/lookup-hm-option](/workflows/lookup-hm-option.md) — covers the home-manager
  side (`configType`, `settings`). It does **not** cover Hyprland's own key vocabulary,
  which is upstream's and moves independently.
