# LID Coach — Visit Planner

## Executive summary

**Posture:** *Bootstrapping — the design arrow is in place and unusually clean; configuration reconciliation and one unrecorded tenet trade-off are the fastest wins.*

**Scorecard**
- ✓ HLD discipline — architecture, tenets, goals, and rationale; no schemas or signatures leaking upstream
- ✓ Linkage hygiene — unique, grep-friendly, namespaced spec IDs (`INTAKE-*`, `FILL-*`), no collisions
- ✓ Mutation hygiene — docs read cold; no change-narration, `[obsolete]` markers, or `[inferred]` residue
- ⚠ Configuration — the `## LID` block is present, but the mandatory directive block is missing
- ⚠ Tenet cascade — the near-term checkout path pulls against "First asked, first served"
- ⚠ Arrow completeness — Tests → Code phases absent while every spec is marked implemented

**Headline:** Your HLD, two LLDs, and EARS layer are genuinely well done — tenets that are real tie-breakers, Decisions & Alternatives tables that actually record accepted costs, and specs whose WHEN clauses disambiguate the two fulfillment variants. The single most valuable next step is to reconcile the instruction-file directives and write down the near-term-checkout trade-off before the first test is written.

## Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** `CLAUDE.md` carries the `## LID` metadata block (Mode / Version) but no LID directive block at all — no `linked-intent-dev` / `Linked-Intent Development` text telling agents to walk the arrow · *modes are declared, not inferred* — the setup must live visibly in the instruction file; without it a fresh session has no cue that code changes flow HLD → LLD → EARS → tests → code. Recommend `/update-lid` to reconcile.
- **F2 (high):** the ≤36h path ("Any eligible signed-in account may complete checkout while it is searchable") lets a later asker claim a scarce same-day opening ahead of an earlier request, working against the "First asked, first served" tenet — and no Decisions row or decision doc records the exception (naming the tenet traded against and why) · *tenets capture forward-looking preference; keep the arrow coherent* — a tenet pre-narrows the choice a future session meets cold; an unrecorded exception means the next reader either "fixes" the speed path or silently extends the fairness break.
- **F3 (medium):** the two-path fulfillment split and its load-bearing parameters (36 hours, 20 minutes, two-hour offer) are choices a cold reader would question, yet they live only in design prose — no Decisions & Alternatives row names the rejected "always-ordered matching" alternative or the accepted fairness cost · *docs carry current intent* — rationale and given-up options belong on the page; left in a past conversation, that reasoning is lost context that compounds every session.
- **F4 (medium):** the two LLDs carry no `parent:` / `prefix:` frontmatter, so `FILL-*` has no authoritative bridge to the `fulfillment` leaf (nor `INTAKE-*` to `intake`) · *effective intent-tree alignment* — spec prefixes should trace to a leaf LLD via `prefix:`; without it a grep-walker has to guess where the path/facet boundary falls. A convention drift `/update-lid` can reconcile.
- **F5 (medium):** every spec is marked `[x]` ("code and tests exist"), but the repo has no tests, no code, and no `@spec` annotations — the Tests → Code phases have not started · *canonical arrow shape; tests carry `@spec` annotations* — status markers should describe real state; consider beginning tests-first implementation or flipping them to `[ ]` so the arrow stays honest.
- **F6 (low):** four HLD tenets sit in an unordered bulleted list, and fairness ("First asked, first served"), clinical fit, and refill speed can pull in different directions (as F2 shows) · *tenets capture forward-looking preference* — consider ordering them so a reader knows which way to lean when two defensible answers collide and no spec covers the case.

## What was audited

- Read fully (6 files): `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (`intake-specs.md`, `fulfillment-specs.md`).
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 15 EARS specs (7 `INTAKE`, 8 `FILL`), 2 arrow segments, 4 tenets, 3 goals, 8 Decisions & Alternatives rows.
- Linkage metric: 0 `@spec` references, 0 test files, 0 code files — no implementation layer present.
- Ran the cold-read pass (all docs read as if with no conversation context — clean, no residue found) and the Decisions-table sweep (8 rows reviewed; the under-captured choice is in prose, not a row).
- Sampling: full read by judgment (small project); arrow-path sampling not triggered — 2 LLDs (< 15), 0 `@spec`-carrying files (< 200), and no `docs/arrows/index.yaml` overlay.
- History: 1 commit (`f54f21a fixture`), so cascade / adjacent-level drift could not be assessed from git.

## Offer to help

Want me to walk through these in detail (the tenet conflict in particular), focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID here — moving from a docs-only arrow into tests-first code, mode transitions, where a PRD would sit, or splitting a segment as fulfillment grows — I can help with those too.

---

*Defaults taken in this non-interactive run (2026-11-11):* dispatched to a **full review anchored on the LID artifacts** (the skill's stated action when the instruction file lacks directives but the project is clearly LID-shaped) rather than refusing or pausing, **defaulting to Full mode** (consistent with the declared `- Mode: Full`; `Version: 1.4.0` matches the installed plugin, so no version-walk, and I trusted the declared Full scope rather than flagging the docs-only state as a gap); used the **small-project judgment-based full read** instead of arrow-path sampling (no thresholds met, no `index.yaml`); **rendered the report inline** rather than persisting it (skill default: inline unless asked); kept the **advisory posture — no files edited**; and **stopped after the report**, treating the offer-to-help as informational (the coach does not iterate, so no follow-up turn was entered). No date-dependent staleness call was needed — there are no `[inferred]` markers and only a single-commit history.