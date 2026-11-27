**LID Coach — Visit Planner**

## Executive summary

**Posture:** *Design-layer arrow is well formed; downstream phases not yet started, and one tenet is being quietly traded away.*

**Scorecard**
- ✓ Mutation hygiene — docs read cold and clean; no history residue, planning text, or obsolete markers
- ✓ LLD granularity & verticalization — two leaves matching the HLD's two components, linked from the HLD, no second navigation axis
- ⚠ Tenet cascade — the fast-cancellation path works against *first asked, first served* with no recorded exception
- ⚠ Decision capture — fulfillment's most questionable choices (36h, 20min, 2h) carry no Decisions row
- ✗ Arrow completeness — `HLD → LLDs → EARS` is real; Tests and Code phases are absent while every spec is marked `[x]`
- ⚠ Configuration — the `## LID` block declares mode and version but no LID directives

**Headline:** The design layer here is genuinely strong — tight HLD with real tenets, two clean leaf designs, 15 well-formed EARS specs with stable IDs and no accumulation anywhere; the highest-value next step is reconciling the `[x]` status markers with the missing tests/code phases, and recording (or revisiting) the fast-cancellation path that currently outranks earlier askers.

## Findings (12 total · 5 high · 5 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode: Full` and `Version: 1.4.0` but no LID directives — nothing tells a fresh session to use the methodology · *modes are declared, not inferred* (an unread mode is a default; cascade rigor and coach dispatch all key off the declaration). Run `/update-lid` to reconcile.
- **F2 (high):** `FILL-003`/`FILL-004` let *any* eligible signed-in account check out a ≤36h opening for 20 minutes before the `enteredAt`-ordered scan runs, which under the HLD's own same-day-cancellation condition passes earlier askers by; no Decisions row names the tenet traded against · *tenets capture forward-looking preference* + *keep the arrow coherent*
- **F3 (high):** All 15 specs are marked `[x]` while the repository contains no tests and no code — the markers can't currently be read as live state · *coherence is adjacency* (each level agrees with its neighbor; here the EARS→Tests seam has nothing on the far side)
- **F4 (high):** The 36-hour threshold, the 20-minute `notBefore` delay, and the two-hour offer window are load-bearing numbers a cold reader would question or want to tune, and the fulfillment Decisions table covers none of them · *decision capture* (docs carry current intent — a live decision needs a row that names what was given up)
- **F5 (high):** The HLD's approach commits to "staff may act for patients who call", but `INTAKE-001` requires "an authenticated account submits" and no design or spec covers delegated entry · *effective intent-tree alignment* (HLD intent with no spec is unnamed intent that drifts silently)
- **F6 (medium):** `FILL-*` specs live under the `fulfillment` leaf, and neither spec file declares `prefix:` frontmatter — the path from ID to owning node isn't mechanically resolvable · *specs are grep-anchored linkage*
- **F7 (medium):** Offers are created (`FILL-001`, `FILL-005`) and expire (`FILL-002`), but no spec covers a patient *accepting* one; the offer→ownership path exists only for the open-checkout route · *LLDs close enough of the solution space*
- **F8 (medium):** The same collection is "interest entries" in intake and "the registry" in fulfillment, and "registry scan" is never defined · *semantic legibility as cheap linkage* (names that disagree across nodes cost tokens on every future read)
- **F9 (medium):** The two-hour offer duration lives in fulfillment design prose with no EARS spec fixing it · *coherence is adjacency* (LLD behavior with no spec has nothing to test against)
- **F10 (medium):** The HLD goal "a traceable explanation for every confirmation, expiry, and withdrawal" and the tenet *explain from durable facts* have append-side specs (`FILL-008`, `INTAKE-007`) but no spec for staff *retrieving* that reconstruction · *effective intent-tree alignment*
- **F11 (low):** `FILL-002` says expiry "releases the opening and runs matching again" without disambiguating whether a ≤36h opening also returns to portal search · *scope disambiguation* (would this still be unambiguous with both variants in play?)
- **F12 (low):** The fulfillment leaf carries matching, claim/ownership, and notification+audit — concerns that share the opening-state model but have separable behavior · *one LLD per intent component — or split into a sub-HLD when it outgrows one node* (a promotion candidate to watch, not a problem today)

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-*`, 8 `FILL-*`), 8 Decisions & Alternatives rows
- Arrow-path sampled: both segments walked end-to-end as far as they go (HLD section → leaf design → spec → ∅ tests → ∅ code); no `@spec` annotations exist, as the repo carries no source or test files
- Overlay: `docs/arrows/` absent, so cascade findings come from doc reading rather than index state
- Cold-read pass: run over all four LID docs plus the instruction file
- Dispatch note: this run is non-interactive, so the skill's stated default was taken — mode read as **Full** from the `- Mode:` bullet, with the missing directive block surfaced as F1 rather than blocking the review

Want me to walk through the findings in detail, focus on a theme or priority (the tenet conflict in F2 and the uncaptured thresholds in F4 are closely related and worth taking together), or work through specific items? You can also pick a single finding to dig into.

If you have broader questions about using LID on this project — when to promote fulfillment into a sub-HLD, how to use status markers before implementation starts, where a PRD would fit alongside the HLD — I can help with those too.