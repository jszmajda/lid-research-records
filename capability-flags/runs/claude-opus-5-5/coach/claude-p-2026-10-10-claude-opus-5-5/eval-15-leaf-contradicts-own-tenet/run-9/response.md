# LID Coach — Shelfwise

## Executive summary

**Posture:** Well-authored intent layer; one design contradicts a tenet, and the arrow stops at specs.

**Scorecard**
- ✓ Spec craft — 13 EARS specs, cleanly triggered, unique stable IDs, each tracing to a design sentence
- ✓ Decision capture (pickup notices) — every row names what was rejected and what cost was accepted, including the Goal 1 trade on expiry
- ✗ Tenet cascade — hold allocation's branch-first rule works against the first tenet, unrecorded
- ✗ Arrow completeness — no tests or code in the repo, yet every spec is marked implemented
- ⚠ Configuration — `## LID` block is present and current (1.4.0), but the LID directives are missing
- ⚠ LLD sufficiency — cancellation and a few delivery/expiry edges are left open

**Headline:** The HLD is lean and architectural, the tenets are real tie-breakers, and the pickup-notices Decisions table is a model of the form. The most valuable next step is to settle whether branch-first allocation is an intended exception to "waiting is honored in sequence", and to record it either way.

## Findings (9 total · 4 high · 4 medium · 1 low)

- **F1 (high):** Branch-first allocation lets a later hold at the scanning branch receive a copy ahead of an earlier hold elsewhere in the county (`hold-allocation-design.md:11`, HOLDALLOC-003/004), against the tenet "nobody's wait is lengthened by a patron who asked after them". PICKUP-005 and HOLDALLOC-007 inherit this by re-running allocation. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say, or record the exception.
- **F2 (high):** The branch-first choice has no Decisions row. Its only rationale is one prose sentence about the courier van, with no rejected alternative, no accepted cost and no mention of the tenet traded. · *decision capture* — a choice a cold reader would question needs its reasoning on the page.
- **F3 (high):** All 13 specs are marked `[x]` (code and tests exist), but the repo holds no tests, no code and no `@spec` annotations. Consider either noting where the implementation lives or resetting the markers. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with each phase present or its absence explained.
- **F4 (high):** `CLAUDE.md` carries the `## LID` block but none of the LID directives (arrow mandate, workflow pointer), so a future session is told the mode but not how to work. `/update-lid` reconciles this. · *modes are declared, not inferred* — configuration lives explicitly in the instruction file.
- **F5 (medium):** Cancellation appears only as the in-transit case. Nothing covers how a hold is cancelled, what happens to a copy already on the holds shelf, or whether a cancelled hold's record is deleted as "hold history is not kept" implies. · *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F6 (medium):** Expiry reads differently at two levels. The design closes the hold when the window lapses; PICKUP-004/005 close it when staff scan the copy off the shelf, leaving open whether the patron can still check out in between. Separately, a lapsed hold sends the patron nothing, which sits oddly beside "each event produces one message". · *coherence is adjacency* — specs agree with the LLD above them.
- **F7 (medium):** Failed delivery is defined for email and SMS only. An unanswered or failed automated-dialer call, the third channel, is not defined, so PICKUP-006 is open for it. · *LLDs close enough of the solution space*.
- **F8 (medium):** The four tenets are an unordered list, though they can pull against each other (F1 is one such case; "hear once" against Goal 2 is another). Consider ordering them. · *tenets capture forward-looking preference* — tie-breakers need a precedence when they conflict.
- **F9 (low):** Neither design doc has `parent:`/`prefix:` frontmatter, so "Pickup notices owns `PICKUP-*`" is inferred rather than declared. `/update-lid` covers this. · *effective intent-tree alignment* — a spec's prefix resolves to its owning design node.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` (6 files, the whole repo).
- Enumerated: 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006), 7 Decisions rows.
- Code and tests: none present to sample; 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not installed.
- Dispatch: the directive strings are absent but the project is LID-shaped, so this was a full review in the declared Full mode. The run was non-interactive and no prompt defaults were needed.

## Next steps

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.