# CLAUDE.md

This is the entry point. It tells you how to *behave* in this repository; the *knowledge* about the repository itself lives in the OKF bundle at [`.okf/`](.okf/index.md).

## Behavioral contract

You are the arbiter of the bundle. That means:

1. **Read before acting.** On any non-trivial task, open [`.okf/index.md`](.okf/index.md) first, then follow links only into the concepts your task actually needs. Progressive disclosure — don't preload the whole thing.
2. **Write back what you learn.** If, while working, you discover something durable that isn't already captured — a new architectural constraint, a fresh hallucination trap, a rebuild gotcha, a "why we did it that way" you had to reconstruct — update the relevant concept file, bump its `timestamp`, and append a dated entry to [`.okf/log.md`](.okf/log.md). Missing knowledge is your responsibility to fix.
3. **Prefer editing existing concepts over creating new ones.** A new file is warranted when a topic is genuinely orthogonal to what's there; otherwise extend. Never touch reserved files (`index.md`, `log.md`) for concept content.
4. **Cross-link generously.** A link asserts a relationship; the kind of relationship is implied by the surrounding prose. Absolute bundle-relative paths (`/architecture/mixin-pattern.md`) are preferred because they survive file moves.
5. **Every concept file needs YAML frontmatter with a non-empty `type`.** That's the only hard OKF rule (§9 of the spec). If a conformance validator (`/okf:validate .okf --strict`) reports errors, fix them before finishing.

## When the bundle contradicts reality

Reality wins. Update the bundle to match, don't cargo-cult stale documentation. The bundle is a mutable map, not a treaty.

## Where knowledge does *not* belong

Do not encode project knowledge in this file. Everything about the mixin pattern, the hosts, the workflows, the reasons behind decisions — those go into `.okf/`, not here. This file stays small and stable so it doesn't drift.

The one exception: if you find yourself repeatedly wanting to remind future-you about a *behavioral* rule (not a fact about the repo — a rule about how you should work), that's a candidate for this file. Facts about the repo go into `.okf/`.

## Companion tooling

* **home-manager option lookup skill** at `.claude/skills/home-manager-options/` — use it before writing config that touches `programs.*` / `services.*` / `wayland.*` etc. Full details in [`/workflows/lookup-hm-option.md`](.okf/workflows/lookup-hm-option.md).
* **OKF validator**: `/okf:validate .okf --strict` — run before declaring bundle changes done.

## Standing rules

* **Do not commit unless asked.** Same policy as everywhere else — you propose the change, the user decides when to land it.
* **Follow the repo's formatting.** Pre-commit will rewrite files on commit (nixfmt, shfmt, ruff-format). Let it. Details in [`/workflows/formatting-and-cspell.md`](.okf/workflows/formatting-and-cspell.md).
