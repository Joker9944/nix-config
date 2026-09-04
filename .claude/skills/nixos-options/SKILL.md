---
name: nixos-options
description: Look up authoritative NixOS system module options (name, type, default, example, description) from the options.json pinned by this flake. Use this skill whenever you are about to write, edit, or review a NixOS `.nix` module — anything touching `services.*`, `boot.*`, `hardware.*`, `networking.*`, `virtualisation.*`, `security.*`, `users.*`, `fonts.*`, `nix.settings.*`, `environment.systemPackages`, `systemd.services.*`, or files under `modules/nixos/mixins/`, `modules/nixos/hosts/<hostname>/`, `modules/nixos/profiles/` — and for any question of the form "does NixOS support X" or "what's the system option for Y". PREFER this over recalled knowledge and PREFER this over reading nixpkgs module source. NixOS options are renamed and restructured constantly (e.g., `hardware.opengl` → `hardware.graphics`, `services.xserver.displayManager.gdm` → `services.displayManager.gdm`, `services.openssh.permitRootLogin` → `services.openssh.settings.PermitRootLogin`), so training-data recall is a hallucination hazard. Also use it when a `nixos-rebuild` fails with "The option ... does not exist", when you find yourself about to open a `nixos/modules/…` source file to find an option, or when you're tempted to guess a submodule shape. It matters most right after a nixpkgs release bump, when recall, the `nix` MCP server, the wiki, and every blog post still describe the release you just left. For *user-level* home-manager options use the `home-manager-options` skill instead.
---

# nixos-options

This skill queries the *pinned* NixOS `options.json` before you write system config. It is generated from the nixpkgs revision `flake.lock` currently pins (release-26.05 at the time of writing), so it describes exactly the option set this flake evaluates against.

`nixos-options` is the system-level sibling of `hm-options`. Same engine, same subcommands, different dataset.

## Which tool for which option

The namespaces overlap — `programs.*` and `services.*` exist in both trees — so pick by **what you are configuring**, not by the attribute prefix:

| You are editing | Tool |
|---|---|
| `hosts/mixins/`, `hosts/<hostname>/`, `modules/nixos/` | `nixos-options` |
| `users/mixins/`, `users/joker9944/config/`, `users/*/hosts/*`, `modules/home/` | `hm-options` |

If a lookup comes back empty, try the sibling tool before concluding the option doesn't exist. `programs.fish.shellAbbrs` is home-manager only; `programs.fish.enable` exists in both and means different things.

## When to call it

Call it **before** writing any system attribute you are not certain exists in this revision:

- Before adding a `services.foo.*`, `hardware.foo.*`, or `boot.foo.*` assignment.
- When you can't remember an option's exact type (`bool`? `listOf str`? `attrsOf submodule`?) — NixOS types are often enums with a fixed value set, and guessing the spelling of a value fails as hard as guessing the option.
- When translating a request like "disable root ssh login" into a concrete option path.
- When a rebuild reports `error: The option 'services.foo.bar' does not exist`.

You do **not** need it for options you just successfully queried this session, for pure nix syntax questions, or for home-manager options.

## During a release upgrade, this is the authority

The dataset is rebuilt from whatever `flake.lock` pins, so the moment nixpkgs is bumped it describes the *new* release while every other source you have — recall, the `nix` MCP server, the wiki, blog posts — still describes the old one. That is when option lookups actually go wrong. Mid-release the two mostly agree and guessing is cheap; right after a bump they diverge and guessing is expensive.

Reading module source doesn't settle it either, because an upgrade has two trees in play and it is easy to read the one you're leaving. This tool only ever answers for the pinned one. See `.okf/workflows/release-upgrade.md` for the bump procedure.

## Keep search narrow — this dataset is large

24,558 options, of which 20,539 are under `services.*`. A broad `search` will flood your context with hundreds of lines and bury the answer:

| Query | Result lines |
|---|---|
| `nixos-options search firewall` | 764 |
| `nixos-options search ssh` | 268 |
| `nixos-options search "openssh authorized"` | a handful |

Because `search` treats whitespace-separated tokens as AND, adding a second word is the cheapest way to cut the result set. Reach for `list <prefix>` as soon as you know the namespace — `list services.openssh` is bounded and complete, whereas `search ssh` is neither. Pipe through `head` when you genuinely want a broad sweep, so a bad guess costs you ten lines instead of eight hundred.

## Prefer this over reading nixpkgs source

If you're about to `Read` a file under `nixos/modules/…` or open a NixOS/nixpkgs GitHub URL to figure out what an option does, **stop and query first**. A `list` + `get` is two shell calls; a nixpkgs module is often 200–1000 lines that will drown your context and still leave you unsure whether the revision you read matches the pinned one. The JSON is generated from the exact pinned tree — it can't lie about what's documented.

Read module source afterwards only for *implementation logic* the description doesn't cover — how a service composes its unit, what a `preStart` actually does.

## "Not found" has two different meanings

This matters more on NixOS than on home-manager, because nixpkgs keeps compatibility aliases that are hidden from the docs. When `get` returns nothing, the option is one of:

1. **Genuinely absent** — wrong name, or removed outright. A rebuild will fail. Use `search` to find the real one.
2. **A renamed alias that still works.** `mkRenamedOptionModule` entries evaluate fine and merely emit a deprecation warning, but they are excluded from `options.json`. `services.xserver.desktopManager.gnome.enable` is missing from the dataset yet still builds, because `nixos/modules/services/desktop-managers/gnome.nix` renames it to `services.desktopManager.gnome.enable`.

So a miss is not proof the config is broken — but it *is* a reason to write the new spelling. When you find existing repo config on a name the dataset doesn't know, that's a deprecated alias worth flagging, not a bug you introduced.

## Options this dataset does not contain

The JSON is built from `eval-config.nix` with `modules = [ ]` (see `pkgs/nix-options/default.nix`), which means stock nixpkgs modules only. Options contributed by flake inputs are **not** in it:

- `disko.*` — imported in `hosts/*/disks.nix`
- `sops.*` — sops-nix
- `home-manager.*` — the home-manager NixOS module
- anything else a third-party `nixosModules.*` brings in

For those, a miss tells you nothing. Read the input's own module source or docs instead.

## Common hallucination traps in 26.05

Options a model is likely to write from memory that are **not** in the pinned dataset. Every replacement below was verified against it.

| Guessed (wrong) | Actual in 26.05 |
|---|---|
| `hardware.opengl.*` | `hardware.graphics.*` (and `driSupport32Bit` → `enable32Bit`) |
| `hardware.pulseaudio.enable` | `services.pulseaudio.enable` |
| `sound.enable` | removed entirely — no replacement |
| `fonts.fonts` | `fonts.packages` |
| `services.xserver.displayManager.gdm` / `.sddm` | `services.displayManager.gdm` / `.sddm` |
| `services.xserver.displayManager.defaultSession` | `services.displayManager.defaultSession` |
| `services.xserver.desktopManager.plasma5` | `services.desktopManager.plasma6` |
| `services.xserver.libinput` | `services.libinput` |
| `services.openssh.permitRootLogin` | `services.openssh.settings.PermitRootLogin` |
| `services.openssh.passwordAuthentication` | `services.openssh.settings.PasswordAuthentication` |
| `nix.autoOptimiseStore` | `nix.settings.auto-optimise-store` |

Two patterns generalize beyond this table, and are worth applying to any option you're unsure of: **things are migrating out from under `services.xserver`** as X11 stops being the assumed display stack, and **daemon config is collapsing into a freeform `settings` attrset** that mirrors the upstream config file's own key names — which is why `PermitRootLogin` is capitalized. Treat the table as non-exhaustive.

## The tool

`nixos-options` is a small binary on `PATH` from this repo's dev shell (defined in `flake.nix`, auto-loaded by `direnv` when you `cd` in). The `options.json` is baked in at build time, so every query is just `jq` — tens of milliseconds, no flake evaluation.

| Command | Purpose |
|---|---|
| `nixos-options path` | Print the resolved `options.json` store path, for piping through `jq` yourself. |
| `nixos-options get <option>` | Full JSON record for one exact option path. |
| `nixos-options list <prefix>` | All option keys under a dot-prefix, one per line. |
| `nixos-options search <keyword>` | Case-insensitive match across keys and descriptions. TSV: `<key>\t<type>\t<description-snippet>`. Multi-word = AND. |

### Typical flow

1. **Search** narrowly if you don't know the namespace: `nixos-options search "openssh root"`.
2. **List** the namespace once you spot it: `nixos-options list services.openssh.settings`.
3. **Get** the options you plan to set: `nixos-options get services.openssh.settings.PermitRootLogin`.

Then write the module using the exact `type` and `default` from the record. If the type is an enum of strings, use one of the listed values verbatim.

## JSON schema (per option)

Each key is a dot-separated option path; the value looks like:

```json
{
  "loc": ["services", "openssh", "settings", "PermitRootLogin"],
  "type": "null or one of \"yes\", \"without-password\", \"prohibit-password\", \"forced-commands-only\", \"no\"",
  "default": {"_type": "literalExpression", "text": "\"prohibit-password\""},
  "description": "Whether the root user can login using ssh.\n",
  "declarations": ["nixos/modules/services/networking/ssh/sshd.nix"],
  "readOnly": false
}
```

Note `declarations` here is a list of **plain repo-relative path strings**, unlike the home-manager dataset's `{name, url}` objects — there is no ready-made GitHub link, and `example` is frequently absent. The fields that carry the weight are `type`, `default.text`, and `description`.

## Failure modes

- **`nixos-options: command not found`** — the dev shell isn't active. `cd` into the repo so `direnv` loads it (`direnv allow` once if prompted), or use `nix develop --command nixos-options …`.
- **`no option 'X' in <json>`** — see "Not found has two different meanings" above before concluding anything.
- **`search` returned hundreds of lines** — add a second keyword or switch to `list`; don't page through it.
- **Truncated `search` output** — descriptions are cut to 120 chars in the TSV. Follow up with `get` for the full record.
