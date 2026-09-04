---
type: Decision
title: Desktop-file facts at build time
description: Nothing reads a package's `share/applications` during evaluation; mime types come from home-manager's `defaultApplicationPackages` and entry existence from a check derivation carried in the entry ID's string context.
tags: [decision, ifd, xdg, desktop-entry]
generated:
  by: claude-code/claude-opus-5
  at: 2026-09-04T00:00:00Z
---

# The rule

A `.desktop` file's contents are only readable by building the package that ships it, so evaluation
never looks. Two mechanisms cover what the tree needs:

* **Mime types** — `modules/home/public/extension/xdg-mime.nix` forwards each path in
  `xdg.mimeApps.custom.apps.default` to home-manager's `xdg.mimeApps.defaultApplicationPackages`,
  which scrapes `MimeType=` with `crudini` in a `runCommand`. Base-file entries keep priority over
  the scraped ones, and packages are appended in list order, so the mixins' `lib.mkOrder` still
  decides who wins a type. Each path is wrapped in a one-file directory first: the option reads
  *every* entry a package holds, which would pull `mpv.desktop` in alongside `umpv.desktop`. The
  wrapper's `install` also fails on a path that no longer exists.
* **Entry existence** — `lib/requireDesktopFile.nix`, see [/architecture/custom-lib](/architecture/custom-lib.md).

# `[Added Associations]` is not worth reproducing

The section was dropped rather than rebuilt at build time, because nothing this tree uses reads it:
`xdg-mime query default` (and so `xdg-open`, and so yazi's *Open*) parses `[Default Applications]`
alone, and `File::MimeInfo` (yazi's *Open with*) ignores sections entirely, then reverses — which
puts the `[Default Applications]` line, sorted after `[Added Associations]`, ahead of it anyway. An
app's own declared types reach `mimeinfo.cache` through `update-desktop-database`, which
`xdg.mime.enable` runs over the profile.

Ordering cannot be expressed for both readers at once: `xdg-open` takes the *first* entry of a list,
`mimeopen` the *last*.

# Known wrinkle

`crudini` matches keys case-insensitively and keeps the spelling of whichever entry wrote first, so
vlc's `audio/AMR-WB` merges into the `audio/amr-wb` that umpv created a step earlier. The canonical
name still resolves — `xdg-mime query default audio/AMR-WB` answers `vlc.desktop` out of
`mimeinfo.cache`, which keeps the case — but its priority is no longer declared here.
