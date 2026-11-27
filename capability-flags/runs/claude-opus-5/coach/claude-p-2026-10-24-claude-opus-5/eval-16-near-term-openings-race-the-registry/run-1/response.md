**LID Coach — Visit Planner**

## 1. Executive summary

**Posture:** Design layer is tight and genuinely cold-readable; the arrow stops at EARS, and the HLD's first tenet and the short-notice fulfillment path pull against each other.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ Intent-tree alignment — 2 components, 2 leaf designs, 2 spec files, 15 specs, clean HLD → leaf links
- ✗ Arrow completeness — Tests and Code phases are absent while all 15 specs are marked `[x]`
- ⚠ Tenet cascade — the ≤36h open-search path can serve a later asker ahead of an earlier one
- ⚠ Decision capture — the 36h / 20min / 2h parameters and the dual-path choice carry no rationale
- ⚠ Configuration — `## LID` block present, but no linked-intent-dev directive block

**Headline:** The design docs are the strongest thing here — four real tenets with defensible opposites, Decisions & Alternatives tables filled in with accepted costs on both leaves, and EARS specs that actually read as EARS. The highest-value next steps are reconciling the instruction file (`/update-lid`) and resolving whether first-asked-first-served or fast refill wins on short-notice openings.

## 2. Findings inventory

**Findings (13 total · 5 high · 6 medium · 2 low)**

- **F1 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full, Version 1.4.0) but no linked-intent-dev directive block, so agents get the mode without the method · *modes are declared, not inferred* — the declaration is what the rest of LID keys off; run `/update-lid`
- **F2 (high):** `fulfillment-design.md:9` / FILL-003–004 make a ≤36h opening claimable by "any eligible signed-in account" for 20 minutes before the earliest-asked entry is offered it, and no Decisions row records the trade · *tenets capture forward-looking preference* — "first asked, first served" says an earlier request is never passed by a later one
- **F3 (high):** no tests and no code anywhere in the repo, yet all 15 specs carry `[x]` · *canonical arrow shape* and *coherence is adjacency* — either the markers overstate state, or the two downstream phases live somewhere the arrow can't reach
- **F4 (high):** "compatible active entries" is the central matching predicate (FILL-001, FILL-005) and is never defined against intake's service / sites / time window / accessibility fields · *LLDs close enough of the solution space* — two agents would implement different matchers
- **F5 (high):** the 36-hour boundary, the 20-minute `notBefore`, and the two-hour offer window appear as bare numbers with no row and no source · *docs carry current intent* (decision capture) — a cold reader would question all three and cannot reconstruct what was traded
- **F6 (medium):** the split into two fulfillment paths is fulfillment's largest architectural choice and has no Decisions & Alternatives row · *docs carry current intent* (decision capture)
- **F7 (medium):** the HLD's Approach and `intake-design.md:4` both have staff acting for callers, but INTAKE-001 says "authenticated account" and FILL-004 "signed-in account" — the staff-proxy actor has no spec · *effective intent-tree alignment* — described behavior with nothing to test against
- **F8 (medium):** FILL-002 releases and rematches, and FILL-001 re-selects the least `enteredAt` — the same entry that just let the offer lapse · *LLDs close enough of the solution space* — no decline, cooldown, or exclusion rule closes the loop
- **F9 (medium):** four tenets in an unordered list, where "first asked, first served" and the goal "refill canceled visits quickly" can disagree (exactly the case F2 lands in) · *tenets capture forward-looking preference* — order them when more than two could conflict
- **F10 (medium):** neither leaf design declares a `prefix:`, and the `fulfillment` leaf owns `FILL-*`, so the path/facet boundary isn't resolvable from the docs · *specs are grep-anchored linkage*
- **F11 (medium):** `intake-design.md` Decisions selects "Append-only events," but only withdrawal appends one (INTAKE-007); the service-change close/recreate (INTAKE-006) and preference edits (INTAKE-005) append nothing · *coherence is adjacency* — the leaf and its specs disagree
- **F12 (low):** no tie-break for two compatible entries with equal `enteredAt` · *LLDs close enough of the solution space*
- **F13 (low):** the fulfillment leaf bundles matching/offers, self-service checkout, and transition+outbox eventing under one EARS segment — worth watching as a promotion candidate if it grows · *one LLD per intent component — or split into a sub-HLD*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/` — the entire repo is 6 files
- Enumerated: 1 HLD, 2 leaf designs, 2 spec files, 15 specs (7 `INTAKE-*`, 8 `FILL-*`), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments walked HLD section → leaf design → spec; both terminate at EARS (no test or code phase exists to sample)
- Linkage metric: 0 `@spec` annotations found — no code or test files present
- Overlay: `docs/arrows/` absent, so no `index.yaml` to read and no `/arrow-maintenance` enumeration available
- Passes run: dimension sweep (all 19), cold-read pass over all four LID docs, Decisions-table sweep over all 8 rows
- Non-interactive run: dispatch found the `## LID` block's `Mode: Full`, so the review ran full-mode project-wide; the missing directive block was taken as drift to surface (F1), not grounds to refuse coaching

Want me to walk through the findings in detail, focus on a theme or priority (the F2/F5/F6 cluster around the short-notice path is one thread; the F3 arrow-completeness question is another), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — how to structure the test and code phases as implementation starts, where PRDs fit against the HLD, or whether fulfillment eventually wants a sub-HLD — I can help with those too.