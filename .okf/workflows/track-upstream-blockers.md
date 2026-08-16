---
type: Playbook
title: Tracking upstream blockers
description: krank reports whether the issue links in workaround comments are still open; the /issues/ URL form it needs, the pre-commit hook that enforces it, and when to reach for krank:ignore-line.
tags: [workflow, krank, upstream, workarounds]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-16T00:00:00Z
---

# Trigger

You are adding a workaround that exists only because of an upstream bug, or you want to know whether
any of the existing ones can go.

# The convention

**The URL in the comment is the marker.** krank scans for issue-tracker links, not for tokens, so
there is nothing extra to write — `HACK` and `WORKAROUND` keep the meanings
[architecture/comment-markers](/architecture/comment-markers.md) gives them. This is the opposite of
`UPGRADE(<release>)`, which encodes a release gap rather than an upstream bug.

`nix run .#krank-tree` scans every tracked file: still-open links report as `info`, closed ones as
`error`, and it exits non-zero if there is any error. Export `GITHUB_TOKEN` to lift the 60
calls/hour anonymous API limit.

This bundle is scanned too, which is what a [decision](/decisions/index.md) ending in "revisit
if …" should exploit: carry the URL that represents the condition, and the decision reports itself
when the ground under it moves.

# Link form

krank matches `/issues/<n>` only. Write pull request links in that form too — GitHub redirects
`/issues/<n>` to `/pull/<n>`, so the link still resolves for a human. The `rewrite-pr-links`
pre-commit hook ([formatting-and-cspell](formatting-and-cspell.md)) does this for `.nix` and `.md`
alike, so a pasted pull request link is normalised rather than silently going untracked. A link
cited for context rather than tracking takes `krank:ignore-line`.

Discussions can never be tracked. Discussion numbers are a separate sequence from issues and pull
requests, so rewriting one would silently point at an unrelated issue. `krank-tree` warns about any
`/pull/` or `/discussions/` link it had to skip.

Some blockers offer nothing krank can read — upstream may not accept issue reports at all. A
stand-in issue in this repo is not a substitute: its state is downstream of your own attention,
closing only once the fix has already been noticed, so it records the blocker without ever
detecting anything. Watch the upstream release stream and subscribe to whatever thread the fix will
be announced in.

# Closed is a prompt, not a verdict

krank reports the *link's* state, which is not the same as the workaround being removable. A pull
request can be merged and still be the thing that **caused** the bug; another can be merged years
before while the real removal condition sits in an untracked source file; an issue can close as
stale. Read the site before deleting anything.

A link that turns out not to be the removal condition still carries context, so it stays and takes
`krank:ignore-line` with a short parenthetical for why it is silenced — the parenthetical is what
distinguishes a deliberate exemption from an unexplained one.

# Related

* [architecture/comment-markers](/architecture/comment-markers.md) — the marker set these links sit
  beside.
* [release-upgrade](release-upgrade.md) — the `UPGRADE(<release>)` marker for the other kind of
  deferred work.
* [formatting-and-cspell](formatting-and-cspell.md) — the hook set `rewrite-pr-links` belongs to;
  regenerating `.pre-commit-config.yaml` after a hook change needs `nix develop .#preCommitHooks`.
* [decisions/renovate-scope](/decisions/renovate-scope.md) — a blocker with no code site, tracked as
  prose instead.
