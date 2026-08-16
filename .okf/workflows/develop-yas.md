---
type: Playbook
title: Develop yas
description: The edit-run-check loop for apps/yas — the four npm scripts over the ags CLI, what `npm run types` produces, type checking, formatting nothing enforces, and how a change reaches the running desktop.
tags: [workflow, yas, ags, typescript]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-17T00:00:00Z
---

# Trigger

You are editing [apps/yas](/apps/yas.md) and want to see or ship the result.

# The four scripts

All of them shell out to the ags CLI through the sub-flake, so run them **from `apps/yas`**:

| Script | Runs | Use |
|---|---|---|
| `npm run run` | `ags run --gtk 4 --directory src` | Live instance straight from `src/`, no build step. |
| `npm run inspect` | `ags inspect` | GTK inspector against the running instance — the way to check which CSS node a widget actually is. |
| `npm run types` | `ags types --update --ignore Gtk3 --ignore Astal3 --directory .` | Regenerates `@girs/`, `tsconfig.json` and the `node_modules` links. |
| `npm run build` | `nix build .` | Standalone build of the bundled executable. |

A dev instance and the installed user unit both create layer surfaces, so you get two bars unless you
`systemctl --user stop yas` first.

# Untracked working state

`@girs/`, `node_modules/`, `package-lock.json` and `tsconfig.json` are all gitignored, and
`npm run types` is what produces them: it writes `tsconfig.json` if absent (rewriting it in its own
two-space style if not), regenerates `@girs/`, and relinks `node_modules/ags` and `node_modules/gnim`
into the `/nix/store` path holding the ags JS library. Run it on a fresh checkout, after bumping the
`ags` or `astal` inputs, and whenever those two symlinks dangle — a garbage collection breaks them, and
every `ags` import then silently resolves to `any` in the editor.

None of it reaches the build. `ags bundle` carries its own JSX settings and resolves `ags`/`gnim`
itself; a package built with `tsconfig.json` deleted is byte-identical to one built with it.

**The generated `tsconfig.json` is not equivalent to a hand-written one.** ags emits no `lib`, so the
project falls back to `target: ES2020` — and `services/workspaces.ts` uses `.at()`, which is ES2022:

```
src/services/workspaces.ts(37,41): error TS2550: Property 'at' does not exist on type 'string[]'.
```

Add `"lib": ["ES2023"]` back after a fresh generation. `@girs/` needs no wiring — `tsconfig.json`
declares no `include`, so every `.d.ts` under the project is ambient, which is what makes
`import Gtk from "gi://Gtk?version=4.0"` resolve.

# Type checking

Nothing in the build checks types: `ags bundle` runs esbuild, which strips them. A full pass needs a
`tsc` you bring yourself (TypeScript is not a devDependency) and `--skipLibCheck`, or the generated
Gtk3 and Gtk4 declarations under `@girs/` collide on duplicate identifiers:

```bash
tsc --noEmit --skipLibCheck -p apps/yas
```

What survives that is upstream noise — the ags JS library ships `.ts` sources importing
`gi://AstalApps`, `AstalBluetooth`, `AstalPowerProfiles` and `AstalTray`, none of which this project
puts in `extraPackages`. Errors under `src/` are yours; anything reported from a `/nix/store` path is
not.

# Formatting is entirely editor-side

Prettier's config lives in `package.json` (no semicolons, `@trivago/prettier-plugin-sort-imports` with
the groups `^ags`, `^gi://`, `^[./]` separated by blank lines), and `.editorconfig` supplies tabs and a
120-column width (the repo-root one covers `.json` with tabs). **No pre-commit hook covers `.ts`,
`.tsx` or `.scss`** — only the repo-wide whitespace and end-of-file hooks touch them, so formatting
drift commits silently. Run `npx prettier --write "src/**/*.{ts,tsx,scss}"` before finishing a change.

A `prettier` hook was tried and reverted, and re-proposing one costs whoever tries it the same
afternoon: nixpkgs ships the same prettier version, but it reads this `package.json` and aborts on
every file because the plugin it declares cannot be resolved without `node_modules`, which
`nix flake check` does not have. Enforcement means dropping the plugin, restating its settings as hook
flags (`--no-config` also disables `.editorconfig`), or packaging the plugin — none of which was worth
it for one formatting incident.

# Getting a change onto the desktop

`nh home switch` from the repo root. The package rebuild restarts the unit; see
[apps/yas](/apps/yas.md) for the `X-Reload-Triggers` that also restart it on a theme or config change.

Note which nixpkgs each path uses: `npm run build` resolves against the sub-flake's own lock, which
pins `nixos-unstable`, while the copy home-manager installs is built with the root's nixpkgs because
the root input `follows` it. A standalone build succeeding does not prove the switch will.

# Related

* [apps/yas](/apps/yas.md) — the code conventions a change has to follow.
* [rebuild](rebuild.md) — the switch commands in full.
* [formatting-and-cspell](formatting-and-cspell.md) — the hook set that does *not* include prettier.
* [decisions/util-lib-split](/decisions/util-lib-split.md) — updating a sub-flake input from the root.
