---
name: okf-trim
description: Trim the `.okf/` knowledge bundle back to terse documentation that points at the right places — compact `log.md`, cut restated authority and change-narrative, check facts still hold against the repo, and route leaked behavioral rules to CLAUDE.md or deletion. Use this when asked to "trim the bundle", "the .okf docs have too much detail", "the docs have spiralled", "compact log.md", "audit .okf for stale facts", "behavioral rules leaked into the docs", or for any deliberate sweep across the whole bundle rather than one concept. Do NOT use it for the routine write-back after a code change (that is CLAUDE.md rule 1), for authoring a new concept, for fixing one known-stale fact you already have in hand, or for OKF conformance errors (that is `/okf:validate`). This skill deletes documentation, so a false trigger is destructive — when the task is "update the bundle" rather than "the bundle has too much in it", it is the wrong tool.
---

# okf-trim

An on-demand sweep that enforces `CLAUDE.md` rules 2 and 3 across the whole bundle. The target is **redundancy, restated authority, and change-narrative** — never density. The bundle's most valuable paragraphs are also its ugliest, and the instinct that "shorter is better" gets this exactly backwards if you let it run unchecked.

Read the two exemplars before you cut anything. They are the calibration — frozen pre-trim snapshots under this skill's `evals/fixtures/density/.okf/`, kept there precisely because the live bundle stops exhibiting the disease the moment a pass succeeds:

* `evals/fixtures/density/.okf/workflows/lookup-hm-option.md` — well-formatted, tidy tables, and roughly two thirds of it is a second copy of `.claude/skills/home-manager-options/SKILL.md`. **This is the bloat.** (A correct trim first reduced the live concept to a pointer; the bundle has since dropped even that — the skill file is the sole authority.)
* `evals/fixtures/density/.okf/architecture/module-layout.md`, the `modules/global/` section — a wall of unbroken prose where every clause is a constraint someone paid for: which tree owns which fontconfig generic, that `extraCss` concatenates so the winning fragment needs `lib.mkAfter`, that a ~220 MiB Nerd Font is why the binding sits in the home glue. **This is what you are protecting.**

## Scope

Takes a scope: the whole bundle (default `.okf/`), a directory, or a single file. Work in four batches, and track them with `TaskCreate` / `TaskUpdate` rather than inventing a worklist file:

1. `workflows/` — highest leak density, cheapest to verify, and the most at risk of over-trimming. Do it while your attention is fresh.
2. `decisions/` — almost no repo verification needed, but **read every one rather than working from the report**. Decision archaeology is routinely phrased in ways the script cannot match, so a clean narrative section here means nothing. See the carve-out below.
3. `architecture/` — the expensive batch, real source reading.
4. `hosts/` and the root files.

## The audit script

`scripts/okf-audit.py --bundle .okf --repo .` (python3 from this repo's dev shell; stdlib only, no third-party packages; `--json` for graders). Run it first — it turns "read 2,000 lines and form an opinion" into "open these lines."

It emits **data, never verdicts.** Every check below was measured against this bundle and every one has a false-positive rate that would make an automatic edit wrong more often than right. Read the hit, then decide.

| Section | What it gives you | How to read it |
|---|---|---|
| narrative | Test C hits, tagged with the concept's `type` | Rewrite to the present, or cut if nothing survives that. A `Decision` is not exempt — its alternatives stay, its description of the replaced state does not |
| duplicate paragraphs | Sentence pairs above a similarity threshold, across bundle files and against `.claude/skills/*/SKILL.md` | The one check a per-file pass cannot make. Top hits are real; parallel sibling files (the two hosts, the two CI decisions) legitimately rhyme. A bundle sentence rhyming with a skill file is Test B's restated authority |
| behavioral candidates | Agent-directed rules only | Small and high-precision by design. A bare second person is a coin flip here and is deliberately not matched, so this list is a floor, not a ceiling |
| reference suspects | Backticked path-like tokens that resolve nowhere | Expect upstream and generated paths (`options.json`, nixpkgs sources, `hyprland.lua`). A hit is a question, not a defect |
| broken bundle links | Internal link targets that do not exist | SPEC §11 forbids the validator rejecting a bundle for these, so this is the only thing that catches them. Run it again at the end — trimming creates them |
| churn | Commits touching each concept's referenced paths since its `generated.at` | **Reading order only, never a defect.** `overview.md` ranks high purely because `flake.nix` churns |
| trust tiers | Which files carry a `verified` entry | Human-reviewed files need a consult before you edit them |
| index bullets vs descriptions | Each index bullet beside the target's own frontmatter `description` | Formatting, not checking — string comparison cannot see a contradiction between two strings that are *supposed* to differ. Scan the pairs yourself |
| log.md | Entry count, char distribution, SHA count, dates with more than two entries | The merge candidates are the dates with several entries |

## The tests

Each one makes you produce an artifact. That is the point — a test you can answer with a feeling is a test you will rationalize past.

### Test A — name the failure

For each unit, name the concrete wrong thing a competent agent does without it. Load-bearing text answers instantly: *puts the font binding in the shared module and adds 220 MiB to the NixOS closure*; *writes `extraCss` without `mkAfter` and is silently overridden*; *calls `hyprctl keyword`, which does not exist under the lua config manager*.

If the best you can produce is "the reader wouldn't know X", it is exposition. Cut it. **Failure to name a failure is the signal.**

### Test B — name the authority

For each claim, name the single place that must change for the claim to become false.

| Authority lives | Do this |
|---|---|
| This file | Keep |
| Another bundle file | Delete here, link there |
| Outside the bundle, in something an agent already reads — a `SKILL.md`, a tool's source, an upstream option description, `flake.nix` | Replace the restatement with a pointer |

Test B is what kills the command table in the `lookup-hm-option.md` exemplar. Not "too long" — "second copy of a fact owned elsewhere." And it is what spares `module-layout.md`, because nothing outside the bundle asserts *why* the font binding sits where it does.

### Test C — present tense or nothing

Every claim about the repo states a present-tense property. Apply the rewrite: can this sentence be said about the repo as it stands, without reference to what it was? If yes, say it that way. If it only parses as history — *used to be / previously / formerly / before this / had been / displaced / an earlier X / renamed to / moved to / replaced by / no longer* — it is archaeology, and git already holds it tied to the diff that made it true.

The failure this prevents is accretion. Each refactor adds a layer of "before this it was X" and nothing ever removes one, so a concept read five refactors from now describes six states instead of one. That is rule 2's "excess is a defect" arriving one sentence at a time.

Watch for the reason wearing history's clothes. "This displaced `self`, which had been the flake lib" looks like archaeology but carries a live constraint: a lib named `self` collides with the flake's own `self` wherever both are in scope. Keep the constraint, state it in the present, drop the displacement. The test is not "does it mention the past" but "does anything survive the rewrite" — and when something does, rewriting beats deleting.

Treat the script's narrative section as a floor, not an inventory. It matches a fixed list of phrasings, and archaeology written any other way passes it silently — *the PAT was load-bearing*, *the move off them was about the vendor*, *removes the GPG step entirely* all describe a setup that no longer exists and none of them match, because a regex broad enough to catch them fires on every past-tense verb in the bundle. For the hits it does return it still cannot tell you which have a survivor. Reading finds the rest; nothing else does.

### Density is not verbosity

The naive prior is backwards, so state the inversion plainly: **formatting is not a signal. Identifier-and-number density per sentence is.** The tidy file was the bloated one.

Never delete a sentence containing a number, a unit, an upstream identifier, a named failure mode, or a *because / so that / otherwise* clause — unless Test B places its authority somewhere else. Those markers are what a constraint looks like when it has been compressed.

### Restructure before you delete

When Test A says keep but the prose is a wall, the move is not deletion — it is one constraint per bullet, dropping connectives only, keeping every identifier and number. Treating "keep" and "shorten" as mutually exclusive is how the good paragraphs die.

**Never work a concept to a line-count target.** Nothing produces over-trimming more reliably. A file that is 90% load-bearing should barely move — and one that grows because you split a wall into bullets is a good outcome, not a failed trim.

This governs concept prose. It does not govern `log.md`, which is an index and does carry a budget — see below.

## Knowledge vs behavior

"Would this apply to any repo?" leaks badly — most modal language in this bundle is a repo-bound constraint ("a nix-schemes library module must never read a transformer-added field"). Use these instead:

* **Grammatical subject.** Subject is the agent or reader → behavioral. Subject is a repo artifact → knowledge, even with a modal verb.
* **Strip the imperative mood; is a fact left?** "Stop and use `hm-options` first" → nothing. "Run `nix run .#test-lib` from that flake's own directory, since `.#` resolves against the working directory" → a fact.
* **A Playbook's fenced commands are knowledge in procedural form.** `workflows/rebuild.md` is almost entirely commands and is not a leak. Never strip them.
* **A Playbook's prose steps are the genuinely hard case — flag them, never cut them on your own judgment.** A `type: Playbook` is procedure by definition, so an imperative in one may be a repo-specific hazard wearing an imperative's clothes: "Read the site before deleting anything" fails the subject test but its payload is a fact about how closed upstream links behave. The subject test is not reliable enough here to delete on. Put every one of these in the consult, with the fact it carries, and keep it if unanswered.

Then route it — three destinations, not two:

1. **Already in `CLAUDE.md`** → delete, no question.
2. **Already carried by a skill's own `description`** → delete, but *confirm the description still carries it first*. `home-manager-options` says "PREFER this over recalled knowledge" in its frontmatter. Deleting the bundle's copy without checking degrades the behavior the bundle exists to protect.
3. **A real working rule that is in neither** → this is the only bucket that becomes a question.

When you delete a behavioral rule that carried a *reason*, keep the reason if it is repo knowledge. "Read the site before deleting anything" is behavioral; "a pull request can be merged and still be the thing that caused the bug" is a fact about how these links behave, and it survives.

## Decisions keep their alternatives, not their archaeology

A third of the concepts are `type: Decision`, and "is this still true of the repo?" applied naively to one rewrites history. Two things in a Decision are load-bearing and stay: **what was considered and refused**, and **the trade-off accepted**. Both are live — they are what stops the same proposal returning next quarter, and neither describes the tree.

What a Decision does *not* earn is a description of the state it replaced. "Before this, one lib answered to four names (`libSchemes`, `colorLib`, `libScheme`, `flake.lib`)" is not a rejected alternative — it is the previous shape of the tree, and no reader can act on it, because none of those names exist anywhere now. The rule it motivated (`One attrset, one name, no aliases`) is already stated a few lines above. Cut it.

The distinction is *was it ever a candidate, or was it merely earlier?* A rejected alternative is a fork in the road that stays interesting forever. A superseded implementation is a place the road used to run, and git holds the map. An alternative that briefly existed as a draft before being dropped is still a fork — keep it.

If the repo no longer embodies the choice, add `status: deprecated` or write the superseding decision. That much never becomes an edit to the old rationale.

## Trust frontmatter

Per SPEC §5.2, `generated.at` marks the content's **last meaningful change** — it is not a "last looked at" field, and bumping it on files you only read destroys the one staleness signal the bundle has.

* Changed the content → bump `generated.at`.
* Read it, checked it against the repo, changed nothing → add `verified: [{ by: claude-code/<model>, at: <now> }]`. That is the machine-confirmed tier, and it makes the pass durable.
* Could not confirm a claim → leave it, add no `verified`, and list it in the closing summary.

**A `verified` entry by `human:joker9944` demotes autonomy.** The trust-tiers section of the report lists which files carry that sign-off. Editing one while leaving its `verified` block attaches a human sign-off to text the human never saw. Human-reviewed files move into the consult set, and any edit drops or refreshes the entry.

## Typical flow

0. Resolve scope, run the audit script, save the report to the scratchpad.
1. **Read-only classification sweep.** Walk the batches and classify — leaks, duplicates, decision status, unconfirmable claims — without editing. Editing here forces a second interruption later.
2. **One consult** (see below).
3. `CLAUDE.md` — promoted rules only, appended as list items to the existing contract. Never a new section per rule.
4. **Per-file pass, one open per file:** verify against the repo, apply A/B/C, restructure, set trust frontmatter. The script produced suspects, not answers, so the verification happens here and only here.
5. **Index reconciliation** for every touched concept — the bullet and the target's own `description` must not contradict each other.
6. **`log.md` in a single edit** — compact the existing entries and add this pass's own entry together. Split across two edits, you will write them under two different mental models.
7. **Verify against the audit, not against your impression.** Re-run the script and check the numbers moved the way you intended: narrative and duplicate counts down, no internal link newly broken, and — if you touched `log.md` — **SHA count at zero and prose inside budget**. Compacting the log has two independent requirements, grammar and length, and satisfying one while quietly dropping the other is the normal failure here; the report is what catches it. Then `/okf:validate .okf --strict`. Report what you did. **Do not commit.**

Do not fan this out to per-file subagents. They re-read the same nix sources N times, they structurally cannot see cross-file duplication — the highest-value finding available — and 31 independently-trimmed files read like 31 files.

## Consulting the user

One batched `AskUserQuestion`. The option axis is the **batch, not the item** — `All` / `None` / `Let me pick` / `Show me the text first` — and you enumerate items only if asked to. Fifteen separate questions is a worse review surface than the diff.

Ask about: behavioral rules in bucket 3, **every prose imperative in a Playbook**, edits to human-verified files, and anything where you are genuinely unsure and guessing wrong would be expensive.

Do not ask about: unconfirmable claims (leave them and list them), sentence-level compression, duplication collapse, or log merging. Those are decided by the rules above and reviewed in `git diff`.

## log.md format

`CLAUDE.md` rule 3 owns the grammar — read it there rather than trusting a copy in this file. Compacting means rewriting every existing entry to match it, and **merging entries that describe one piece of work**: five entries about a single theme refactor on one date is one or two lines, not five.

**Entry prose belongs under roughly 100 characters, counting the description only and not the link markup.** This is a real budget, and it is the one place in this skill where a number is the right instrument: the log is an index, so an entry you cannot compress to a clause is not a long entry — it is a concept that is missing the detail. Push the detail into the concept and link to it.

Measure the prose, not the raw line. A `— [architecture/module-layout](/architecture/module-layout.md)` suffix is 60-odd unavoidable characters and tells you nothing about whether the entry is compact. Merging alone will not get you there: it reduces the entry *count* while leaving every surviving entry as long as it was.

Keep the `## YYYY-MM-DD` headings and their order. Every entry that carried a concept link keeps one. Merge, never drop — an entry disappearing loses a distinct change.

**This pass writes one log entry, not twelve.** One line if you changed the format itself, because that changes how a reader interprets every line above it. Zero for the trims: compressing, restructuring, deduplicating and retensing all leave the bundle asserting exactly what it asserted before, so there is nothing to index, and a log full of bundle-maintenance narrative is the defect rule 3 exists to prevent. The log already carries entries of that kind — do not add more.

**A corrected fact is not a trim.** When the bundle asserted something false and now asserts something true, a reader who believed the old claim was misled, and the log is the only place they would ever see it move. Those earn a line, and `CLAUDE.md` rule 1 already asks for one. Two brakes stop this reopening the floodgate:

* **Did the claim change, or only the wording?** A tighter sentence saying the same thing is a trim. A sentence that says something different is a correction.
* **Would a reader who believed the old version have done anything differently?** If nothing follows from it — a missing item in an enumeration, an index bullet that lagged its own concept — it is below the bar. Fix it silently.

Write the entry as the knowledge, never as the maintenance: `- Hyprland is pinned to an upstream tag, not the default branch — [concept]`, not "corrected the hyprland pin". Phrased that way it reads like every other line in the index, which is exactly the test for whether it belongs in one.

## What this skill must not do

* Work a concept to a line count, a percentage, or any numeric target. (`log.md` entry prose is the one exception, and it has a stated budget.)
* Delete a sentence carrying a quantified or named constraint because it reads badly. Restructure it.
* Write itself a concept under `.okf/workflows/` — that recreates the `lookup-hm-option` duplication one level up, in the same pass that fixes it.
* Strip a Playbook's commands.
* Rewrite a Decision's rationale to match the present.
* Commit. Standing repo rule: propose, let the user land it.

A second run on an already-trimmed bundle must produce **no edits**. The report will not be empty and is not meant to be: mapping arrows, a rejected alternative, a concept's own frontmatter `description` keep surfacing because the script matches phrasings and cannot know which ones you already judged and kept. Stability is the invariant, not silence — the same hits, the same verdicts, no diff. If a second pass keeps finding things to cut, the tests are being applied as taste rather than as tests, and the bundle erodes a little each time.

## Failure modes

* **`okf-audit.py: No such file or directory`** — run it by path from the repo root: `python3 .claude/skills/okf-trim/scripts/okf-audit.py`.
* **`python3` missing or `error: tool 'python3' not found`** — the darwin host has no system Python (`/usr/bin/python3` is a broken xcrun shim); python3 comes from this repo's dev shell (`direnv`, or `nix develop`).
* **`okf-audit: no bundle at <path>`** — `--bundle` points somewhere without an OKF tree. From the repo root the default `.okf` is correct.
* **Reference suspects full of `<placeholder>` paths** — the filters dropped a case. Fix `looks_like_path`, don't work around it by ignoring the section.
* **`/okf:validate` passes but links are broken** — expected. SPEC §11 forbids rejecting a bundle for broken cross-links; the audit script's link section is what catches them.
* **The diff is enormous and mostly deletions** — stop and re-read the two exemplars. A healthy pass is lopsided: a few files collapse, most barely move.
