---
type: Playbook
title: Develop yas
description: The edit-run-check loop for apps/yas — the four npm scripts over the ags CLI, regenerating @girs, formatting nothing enforces, and how a change reaches the running desktop.
tags: [workflow, yas, ags, typescript]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Trigger

You are editing [apps/yas](/apps/yas.md) and want to see or ship the result.

# The four scripts

All of them shell out to the ags CLI through the sub-flake, so run them **from `apps/yas`**:

| Script | Runs | Use |
|---|---|---|
| `npm run run` | `ags run --gtk 4 --directory src` | Live instance straight from `src/`, no build step. |
| `npm run inspect` | `ags inspect` | GTK inspector against the running instance — the way to check which CSS node a widget actually is. |
| `npm run types` | `ags types --update --ignore Gtk3 --ignore Astal3 --directory .` | Regenerates `@girs/`. |
| `npm run build` | `nix build .` | Standalone build of the bundled executable. |

A dev instance and the installed user unit both create layer surfaces, so you get two bars unless you
`systemctl --user stop yas` first.

# Untracked working state

`@girs/`, `node_modules/` and `package-lock.json` are all gitignored — a fresh checkout type-checks
against nothing until you populate them. `@girs/` is picked up because `tsconfig.json` declares no
`include`, so every `.d.ts` under the project is ambient; that is what makes `import Gtk from
"gi://Gtk?version=4.0"` resolve. Re-run `npm run types` after bumping the `ags` or `astal` inputs,
otherwise the declarations describe libraries the bundle no longer links against.

`node_modules/ags` and `node_modules/gnim` are symlinks into `/nix/store`. They dangle after a garbage
collection and the editor silently loses every `ags` type until they are reinstalled — the bundler
itself is unaffected, it resolves those imports on its own.

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
