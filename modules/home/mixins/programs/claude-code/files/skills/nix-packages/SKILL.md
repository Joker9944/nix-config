---
name: nix-packages
description: Resolve nixpkgs package attribute names and versions, and answer whether a package exists at all. Use this before writing any package into a Nix file (`home.packages`, `environment.systemPackages`, `buildInputs`, `nix-shell -p`, an overlay), and for any question of the form "is X in nixpkgs", "what's X called in nixpkgs", "what version of X do we have", "why can't nix find X", or "is X available on this channel". PREFER this over recalled knowledge, over `nix search`, and over search.nixos.org or anything backed by it — that index covers one evaluated channel snapshot per platform and silently omits whole package sets, so it reports first-class nixpkgs packages as missing. Also use it when a build fails with `attribute 'foo' missing`, when a package seems to have disappeared between releases, when you are about to guess at an attribute path, or when a version you found disagrees with what the project pins. Packages only — for NixOS or home-manager *options*, use the `nixos-options` / `home-manager-options` skills.
---

# nix-packages

A package lookup has two separable questions, and merging them is how these
tools come to report real packages as missing:

| | Question | Answered by | Authority |
|---|---|---|---|
| discovery | "what is it *called*?" | `nh search packages` | none — a hint generator |
| verdict | "does it exist, at what version?" | the project's pinned nixpkgs | authoritative |

**A search miss is never a "not in nixpkgs" verdict.** Search indexes are built
from one evaluated channel snapshot per platform and omit entire package sets —
`pkgsStatic.busybox` and `pkgsCross.*` return zero hits while evaluating fine.
Only the verdict tier can answer absence, and only in the one form below.

## Verdict — use the script

```bash
scripts/nix-pkg ripgrep dockerTools pkgsStatic.busybox nodePackages.prettier
```

It walks up from the working directory for a `flake.nix`, evaluates against that
flake's `nixpkgs` input for `builtins.currentSystem`, and prints one of four
results per attribute. `NIX_PKG_FLAKE=<dir>` overrides the flake; with no flake
anywhere it falls back to the registry's nixpkgs and says so, because that is a
different question from what the project pins.

| Result | Meaning |
|---|---|
| `EXISTS version=…` | Settled. |
| `EXISTS version=(no version attr)` | Exists; simply carries no `version`. |
| `RENAMED/REMOVED` | Reachable but throws — the message **names the replacement**. |
| `MISSING` | Genuinely absent. The only true negative. |

Prefer the script over a hand-rolled `nix eval` because the distinctions above
are structural, not a matter of reading an error string carefully:

* **`version` is not existence.** `dockerTools` exists, but `dockerTools.version`
  raises `attribute 'version' missing` — the same words you get for a package
  that truly isn't there. Anyone eyeballing that error concludes `dockerTools`
  was removed from nixpkgs.
* **A `throw` is the most useful answer available.** `nodePackages` and
  `linuxPackages.zfs` are gone, and each alias says what to use instead
  (top-level `prettier`; `zfs_*`). Treating the throw as "broken" throws away
  the migration path.
* **An eval failure is not a verdict.** `builtins.getFlake` ignores untracked
  files, so one `git add`-less file fails the whole evaluation. The script says
  so and exits rather than reporting anything as absent.
* **Don't read `flake.lock` by node name.** The node spelled `nixpkgs` is
  frequently some dependency's nixpkgs; the root flake's input can resolve to
  `nixpkgs_2` or further. In this repo those are two different revisions, so
  picking the obvious-looking node reports the wrong pin — and it will often
  still agree on the version, which is what makes it hard to notice. Asking
  `getFlake` for `.inputs.nixpkgs` resolves the indirection correctly.

If you must do it by hand, keep existence and version apart:

```bash
nix eval --impure --expr 'let p = (builtins.getFlake (toString ./.))
  .inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  in { exists = p ? dockerTools; version = p.dockerTools.version or null; }'
```

One scope caveat: this answers what the *pin* holds, which is not always what
the machine is running. A booted system can sit on an older revision than
`flake.lock` until the next rebuild, so "what do we actually get" may mean the
pin, the booted system, or the binary on `PATH`. Say which one you answered.

## Discovery — only to find a name

```bash
nh search packages -c "$(grep -oP 'nixpkgs/\K[\w.-]+' flake.nix | head -1)" -j -l 50 <query>
```

* Take the channel from the project's `flake.nix`, as above. `nh` defaults to
  `nixos-unstable`, which for a release-pinned project reports versions the
  project will never build — unstable said `ripgrep` 15.2.0 against a pin of
  15.1.0.
* `-j` keeps the output from becoming terminal-hyperlink noise.
* Ranking is fuzzy and the exact attribute often isn't last, despite nh printing
  "most relevant results at the end". Scan for an exact `package_attr_name`
  rather than reading the tail.

Feed the names it suggests into the verdict tier. That is all discovery is for.

## Scope

Packages. For NixOS or home-manager options use `nixos-options` /
`home-manager-options`, which read the same pinned revision. Where neither is
available, read the option out of the pinned module tree — don't guess, and
don't fall back to a search index.

`nh` comes from this configuration's `nh` mixin; `nix` and `python3` are always
present.
