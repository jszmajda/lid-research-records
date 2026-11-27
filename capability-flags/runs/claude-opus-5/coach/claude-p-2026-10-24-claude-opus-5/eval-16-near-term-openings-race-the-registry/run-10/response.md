**LID Coach — Visit Planner**

## Executive summary

**Posture:** Clean, well-shaped docs arrow — the design layer is in good order; the strongest openings are a tenet that the fulfillment design quietly works against, and the fact that the arrow stops at specs.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, no `[obsolete]` residue, no "was X, now Y"
- ✓ HLD discipline — problem/approach/tenets/goals/components, with no schemas, signatures, or pseudocode leaking upstream
- ✓ LLD granularity — two leaves, one EARS segment each, no overlap; `INTAKE-*` and `FILL-*` resolve cleanly
- ⚠ Tenet cascade — the ≤36-hour open-claim path leans against *first asked, first served* with no recorded exception
- ⚠ Decision capture — the two-path 36h/20min design, the project's most consequential choice, has no Decisions row
- ✗ Arrow completeness — every spec is marked `[x]`, but no tests or code exist in the repo
- ⚠ Configuration — `CLAUDE.md` declares mode and version but carries no LID directive block

**Headline:** The hard part is done well — the HLD carries real tenets with defensible opposites, both LLDs close most of their solution space, and all 15 specs are EARS-shaped with stable, grep-anchored IDs. The fastest win is reconciling the fulfillment design with the *first asked, first served* tenet (or recording the exception); after that, reconcile the instruction file with `/update-lid`.

## Findings (11 total · 4 high · 5 medium · 2 low)

- **F1 (high):** The ≤36h path lets any eligible signed-in account check out during the 20-minute window, so a later requester can take an opening ahead of the earliest `enteredAt` entry — no Decisions row names the trade · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets say to lean
- **F2 (high):** The 36-hour split and the 20-minute `notBefore` delay — the choice a cold reader would most want to reverse — appear only as design prose; the Decisions table covers locks, eligibility, notifications, and expiry but not this · *decision capture*
- **F3 (high):** Tests and Code phases are absent from the repo entirely while all 15 specs carry `[x]` status markers · *canonical arrow shape* — a half-built arrow can't do edge detection, and `[x]` on an unimplemented spec makes the status marker unreliable for every future session
- **F4 (high):** `CLAUDE.md` has a `## LID` block with `Mode: Full` and `Version: 1.4.0` but no linked-intent-dev directive text — run `/update-lid` to reconcile · *modes are declared, not inferred*
- **F5 (medium):** "Compatible," "eligible," and "clinical fit" carry the matching logic across FILL-001/004/005/006 but no design node owns the eligibility rules · *LLDs close enough of the solution space* — two agents would implement compatibility differently
- **F6 (medium):** FILL-002 ("when an offer expires, release and rematch") reads as universal but the two opening paths differ — does a released ≤36h opening return to portal search, or only to matching? · *scope disambiguation*
- **F7 (medium):** Changing the requested service resets `enteredAt` (INTAKE-006), costing queue position under *first asked, first served* — a live decision with no row recording what was given up · *decision capture*
- **F8 (medium):** The four tenets are an unordered list, yet *first asked, first served* and *clinical fit precedes utilization* can both bear on the same match · *tenets capture forward-looking preference* — order them so the tie-break is decidable
- **F9 (medium):** FILL-007 commits a notification to the outbox, but no leaf owns delivery — drain, retry, dedupe, and failure are unnamed intent · *effective intent-tree alignment*
- **F10 (low):** Neither spec file declares `prefix:` frontmatter; the `FILL-` → `fulfillment` mapping is inferred from directory position rather than stated · *specs are grep-anchored linkage*
- **F11 (low):** The intake Decisions table accepts "keys require expiry state" as a cost, but no spec or design text sets the key lifetime · *LLDs close enough of the solution space*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-*`, 8 `FILL-*`), 2 Decisions & Alternatives tables totaling 8 rows
- Cold-read pass: all 5 LID docs read without conversation context
- Linkage metric: 0 `@spec` annotations — no code or test files exist in the repository
- Arrow overlay: `docs/arrows/` absent, so no `index.yaml` audit; mode defaulted to the declared `Full`, and the full project tree was reviewed
- Git history: single commit, so tests-first evidence could not be assessed from commit ordering

---

Want me to walk through any of these in detail, focus on a theme (the tenet/fulfillment tension is the richest thread), or work through specific items together? Pick a finding and I'll go deep on it.

If you have broader questions about using LID on this project — when to promote a leaf to a sub-HLD, how to handle a cross-cutting concern like eligibility or notifications, or what tests-first looks like when the specs are already written — I can help with those too.