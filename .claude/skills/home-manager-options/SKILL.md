---
name: home-manager-options
description: Look up authoritative home-manager module options (name, type, default, example, description) from the JSON pinned by this flake. Use this skill whenever you are about to write, edit, or review a home-manager `.nix` module — anything touching `programs.*`, `services.*`, `wayland.*`, `home.*`, `xdg.*`, `gtk.*`, `qt.*`, `systemd.user.*`, or files under `users/mixins/`, `users/joker9944/config/`, `users/*/hosts/*` — and for any question of the form "does home-manager support X" or "what's the option for Y". PREFER this over recalled knowledge and PREFER this over reading home-manager source files. Home-manager options get renamed and restructured between releases (e.g., `programs.direnv.enableNixDirenv` → `programs.direnv.nix-direnv.enable`, `programs.vscode.extensions` → `programs.vscode.profiles.<name>.extensions`), so training-data recall is a hallucination hazard. Also use it when a `nix build` fails with "The option ... does not exist", when you find yourself about to open a `<home-manager/modules/…>` source file to find an option, or when you're tempted to guess a submodule shape.
---

# home-manager-options

This skill lets you query the *pinned* home-manager options.json before writing home-manager config. That JSON is the source of truth for this flake — it's generated from whatever home-manager revision `flake.lock` currently pins (release-26.05 at the time of writing).

## When to call `hm-doc`

Call it **before** writing any home-manager attribute you are not 100% sure exists in this revision. Concretely:

- Before adding a `programs.foo.something` or `services.foo.something` assignment.
- When you can't remember the exact type of an option (`bool`? `listOf str`? `attrsOf submodule`?).
- When choosing between two similar-sounding options (`programs.git.userName` vs `programs.git.signing.key` — quick `list` disambiguates).
- When translating a request like "enable ssh support for gpg-agent" into a concrete option path.
- When a user reports an eval error like `error: The option 'programs.foo.bar' does not exist` — check whether it was renamed or removed.

You do **not** need to call it for:
- Options you have just successfully queried in this session (they won't have changed).
- Pure syntax questions (e.g., how to write a nix `let` block).
- NixOS system options — this JSON is home-manager only.

## Prefer `hm-doc` over reading home-manager source

If you're about to `Read` a file under `<home-manager/modules/…>` or a nix-community/home-manager GitHub URL to figure out what an option does, **stop and use `hm-doc` first**. A `list` + `get` is two shell calls and a few hundred characters of output; opening a module source is often 500–2000 lines of nix that will drown your context and still leave you unsure whether the version you're reading matches the pinned revision. The JSON is generated from the exact pinned tree — it can't lie about what exists.

The only reason to read source afterwards is if you need to understand *implementation logic* the description doesn't cover (e.g., how a `mkMerge` inside the module composes). For "what's this option called / what type is it / what's a valid example," `hm-doc` is faster, cheaper, and authoritative.

## Common hallucination traps in 26.05

These are options a model is likely to write from memory that **do not exist** in the pinned revision. Look them up before writing.

| Guessed (wrong) | Actual in 26.05 |
|---|---|
| `programs.vscode.extensions` | `programs.vscode.profiles.<name>.extensions` — extensions, `userSettings`, `keybindings` all moved under `profiles.<name>` |
| `programs.direnv.enableNixDirenv` | `programs.direnv.nix-direnv.enable` (same for `mise.enable`) |
| `programs.fish.abbreviations` | `programs.fish.shellAbbrs` |
| `services.gpg-agent.sshSupport` / `.enableSSHSupport` | `services.gpg-agent.enableSshSupport` |

Consider this table non-exhaustive — the point is that the exact-name recall is unreliable. When in doubt, `hm-doc list <namespace>` and `hm-doc get <path>`.

## The tool

The entrypoint is `.claude/skills/home-manager-options/scripts/hm-doc`. Run it from the repo root (it needs to evaluate `.#home-manager-docs-json`). Four subcommands:

| Command | Purpose |
|---|---|
| `hm-doc path` | Print the resolved `options.json` store path. Useful if you want to pipe through `jq` yourself for anything the subcommands don't cover. |
| `hm-doc get <option>` | Full JSON record for one exact option path. Use when you know the name and need type/default/example/description. |
| `hm-doc list <prefix>` | All option keys under a dot-prefix, one per line. Use for "what does this module expose" — e.g., `hm-doc list programs.neovim`. |
| `hm-doc search <keyword>` | Case-insensitive substring match across keys and descriptions. TSV output: `<key>\t<type>\t<description-snippet>`. Use when you know the concept but not the path. |

### Typical flow

1. **Broad search** if you don't know the namespace: `hm-doc search "gpg agent"`.
2. **List** the namespace once you spot it: `hm-doc list services.gpg-agent`.
3. **Get** the specific options you plan to set: `hm-doc get services.gpg-agent.enableSshSupport`.

Then write the module, using the exact `type` and `default` from the record. If the JSON says `"type": "boolean"` and `"default": {"text": "false"}`, don't wrap the value in a list or a string.

## JSON schema (per option)

Each key in `options.json` is a dot-separated option path (e.g., `"programs.fish.shellAbbrs"`), and the value looks like:

```json
{
  "loc": ["programs", "fish", "shellAbbrs"],
  "type": "attribute set of string",
  "default": {"_type": "literalExpression", "text": "{ }"},
  "example": {"_type": "literalExpression", "text": "{ ll = \"ls -l\"; }"},
  "description": "An attribute set that maps aliases…",
  "declarations": [{"name": "<home-manager/modules/programs/fish.nix>", "url": "https://…"}],
  "readOnly": false
}
```

The fields that matter most when writing config: `type`, `default.text`, `example.text`, and `description`. `declarations[].url` is a working link to the source module on GitHub for the pinned revision — useful when you need context beyond what the description gives.

## Failure modes

- **`'nix build .#home-manager-docs-json' failed`** — you're probably not in the repo root, or the flake input needs to fetch. Cd to the nix-config repo and retry. If the fetch itself failed (no network), fall back to the last built store path (`ls /nix/store/*-options.json 2>/dev/null`) and tell the user the JSON might be stale.
- **`no option 'X' in <json>`** — either the name is wrong (try `search`) or the option was renamed/removed in this revision. Look at the closest matches in the search output.
- **Truncated `search` output** — descriptions are cut to 120 chars in the TSV. Follow up with `hm-doc get` for the full record if the snippet looks promising.
