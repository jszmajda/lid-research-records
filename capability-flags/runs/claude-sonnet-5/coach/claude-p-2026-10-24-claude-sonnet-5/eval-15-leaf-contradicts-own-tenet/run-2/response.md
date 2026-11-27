# `/lid-coach` Report — Shelfwise

## Executive summary

**Posture:** Specs-first and clean, with one tenet undercut by its own mechanism.

**Scorecard**
- ⚠ Configuration — the `## LID` block declares Mode and Version, but the instruction file never contains the `linked-intent-dev` directive text itself
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode leaked upstream
- ✓ LLD granularity — one LLD per intent component, no lumping or fragmentation
- ✓ Mutation hygiene — both LLDs and the HLD read clean on a cold pass: no narration, no leftover context, no stale markers
- ⚠ Tenet cascade — hold allocation's branch-first rule can seat a later-placed hold ahead of an earlier one, which cuts against the "waiting is honored in sequence" tenet
- ⚠ Tenet quality — one tenet reads as an already-made decision rather than a forward-leaning tie-breaker

**Headline:** The HLD and both LLDs are lean and genuinely cold-readable, with decision rows that already carry their alternatives and costs — that's the hard part, and it's in good shape. The most valuable next step is checking the branch-first allocation rule against the sequencing tenet it seems to quietly trade away, with a quick instruction-file reconciliation via `/update-lid` as a fast second win.

## Findings (5 total · 2 high · 1 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block sets Mode and Version but never states the `linked-intent-dev` directive itself · *modes are declared, not inferred* — the mode marker is readable, but the directive block it should sit inside is missing. Recommend `/update-lid` to reconcile.
- **F2 (high):** Hold allocation's branch-first routing (`hold-allocation-design.md`) can serve a hold placed *later* ahead of one placed *earlier*, whenever the earlier hold's pickup branch differs from the scanning branch — an undocumented exception to the "waiting is honored in sequence" tenet · *tenet cascade*.
- **F3 (medium):** The "Hold history is not kept" tenet reads as a decision already made (and enforced by HOLDALLOC/PICKUP specs that delete records on close) rather than a forward-leaning tie-breaker for an undecided case · *tenets capture forward-looking preference*.
- **F4 (low):** The HLD's four tenets are an unordered list, though "waiting is honored in sequence" and "staff attention goes to exceptions" could plausibly conflict · *tenets capture forward-looking preference*.
- **F5 (low):** No tests or code exist yet against the 13 EARS specs — expected at this stage since specs are leading implementation, flagged only so arrow completeness has a marker to track as code lands · *canonical arrow shape*.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files (`hold-allocation`, `pickup-notices`)
- Enumerated: 2 intent components, 2 LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`)
- No `docs/arrows/` overlay present; no code or test files exist in the repo yet, so the arrow currently ends at the EARS layer

*(Full mode — no out-of-scope section.)*

## Want to go further?

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.