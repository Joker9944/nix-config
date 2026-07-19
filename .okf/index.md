---
okf_version: "0.1"
---

# nix-config knowledge bundle

The durable knowledge about this repository lives here — the "why" behind the shape, the non-obvious rules, and the workflows that touch more than one file. Read [overview](/overview.md) first for orientation, then follow links only into the concepts your task actually needs.

# Overview

* [overview](overview.md) — What this repo is, at a glance.

# Architecture

* [architecture/](architecture/) — The mixin pattern, auto-discovery, entry points, and the custom `lib` loader. Read this before making structural changes.

# Hosts

* [hosts/](hosts/) — Per-machine facts (hardware, monitor layouts, quirks).

# Workflows

* [workflows/](workflows/) — How to rebuild, add a mixin, look up a home-manager option, handle secrets, and satisfy the formatter/spellchecker.

# Decisions

* [decisions/](decisions/) — Why the repo looks the way it does. Consult before proposing structural changes.

# Meta

* [log](log.md) — Chronological change history for this bundle.
