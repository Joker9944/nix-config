---
type: Architecture Pattern
title: Comment markers
description: The four intent markers used in code comments — TODO, WORKAROUND, HACK, UPGRADE — what each promises about how long the code stays, plus the optional docker-style id that groups one marker spanning several files.
tags: [architecture, convention, comments, markers]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-12T00:00:00Z
---

# Intent markers

| Marker | Why the code is there | How long it stays |
|---|---|---|
| `TODO` | work not done yet | until someone does it |
| `WORKAROUND(<id>)` | the underlying problem cannot reasonably be fixed here | indefinitely, by intent |
| `HACK(<id>)` | a bug in an upstream dependency | dropped as soon as upstream ships |
| `UPGRADE(<release>)` | the pinned release lacks a feature that a later one has | until that release lands |

`WORKAROUND` and `HACK` have the same shape and differ only in intent: a `HACK` is debt you mean to
repay, a `WORKAROUND` is a decision you mean to keep. Picking the wrong one misleads whoever greps
next — and, for a `HACK`, quietly drops the expectation that anyone will ever revisit it.

`UPGRADE` is the exception that takes a release rather than an id;
[workflows/release-upgrade](/workflows/release-upgrade.md) owns its shape and the bump procedure.

# The id

Docker-style `adjective-surname`, and **optional**. It exists so that one marker spanning several
files can be pulled up as a unit — `grep -rn 'WORKAROUND(stoic-ritchie)'` — so a marker with a
single site does not need one, and every site in a group carries the same id. The id is arbitrary
and carries no meaning beyond joining its sites.

# Tool directives

Distinct from the above: these are read by a program, not a person, and say nothing about why the
code exists.

| Directive | Read by | Owned by |
|---|---|---|
| `krank:ignore-line` | krank | [workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md) |
| `cSpell:ignore`, `cSpell:words`, `cSpell:disable-line` | cspell | [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md) |

# Related

* [workflows/track-upstream-blockers](/workflows/track-upstream-blockers.md) — the upstream issue URL
  that usually sits beside a `HACK`, and how its state gets checked.
* [workflows/release-upgrade](/workflows/release-upgrade.md) — the `UPGRADE(<release>)` procedure.
* [workflows/formatting-and-cspell](/workflows/formatting-and-cspell.md) — the hooks and dictionaries
  behind the cspell directives.
