---
type: Decision
title: CI commits are authored and signed as a GitHub App
description: Update workflows mint a short-lived GitHub App installation token; commits are created through the API so GitHub signs them and they are attributed to the app, not to a person. No GPG key and no PAT in CI.
tags: [decision, ci, secrets, signing]
generated:
  by: claude-code/claude-opus-5
  at: 2026-08-12T00:00:00Z
---

# The rule

`.github/composites/update-pr` is the only place CI identity is wired. It mints an installation
token with `actions/create-github-app-token`, then hands that token to
`peter-evans/create-pull-request` with `sign-commits: true`, which builds the commits through the
GitHub API rather than pushing local ones.

Repo state this depends on: variable `APP_CLIENT_ID`, secret `APP_PRIVATE_KEY`, and an App
installed on this repo with `Contents` and `Pull requests` at read & write. The private key is the
credential — the App's client secret belongs to the OAuth user flow and is unused.

Workflow `permissions` therefore only cover checkout and the nix cache; every write goes through the
app token, not `GITHUB_TOKEN`.

Steps that commit before `update-pr` runs — `nix flake update --commit-lock-file`, `nix-update
--commit` — need a local git identity, because a runner's hostname has no domain and git refuses to
auto-detect one. `.github/composites/git-identity` supplies a placeholder. Its value is irrelevant:
`sign-commits` cherry-picks those commits into API-created ones, preserving each message but
replacing the identity with the app's.

# Why

* **Attribution.** Importing a GPG key in CI also sets `user.name` / `user.email` from the key's
  UID, so nightly dependency bumps end up authored under a personal name. Bot work should read as
  bot work.
* **Blast radius.** A signing key held in CI can forge commits under that identity anywhere, with
  no expiry. An installation token lasts an hour and is scoped to one repo and two permissions.
* **The PAT was load-bearing for the wrong reason.** It existed only because PRs opened with
  `GITHUB_TOKEN` don't trigger `on: pull_request`, which would strand `nix-flake-check` and hang
  automerge. App tokens do trigger it, so the PAT goes too.
* **Signing then costs nothing.** `sign-commits` requires a bot token — a PAT silently produces
  unsigned commits — so it comes free with the app token and removes the GPG step entirely.

# Trade-off accepted

* **Signatures are GitHub-side.** They verify in the web UI and API, not offline and not after a
  mirror to another forge. A self-held key would survive that; it isn't worth the two properties
  above.
* **Out-of-band state.** The App registration, its installation, and the key rotation are not
  described by this repo. `create-github-app-token` failing to mint a token is the symptom.
* **40MiB per blob.** API-created commits cap file size. Lock files and package definitions are
  nowhere near it.

# Related

* [workflows/dependency-updates](/workflows/dependency-updates.md) — the workflows this composite
  serves.
* [decisions/renovate-scope](renovate-scope.md) — the other half of the update pipeline, which
  brings its own bot identity.
