## LID Coach — Shelfwise

**Posture:** *Strong design layer; the arrow stops at EARS, and configuration is thin.*

**Scorecard**
- ✓ Design discipline — the HLD stays at architecture altitude (no schemas or signatures in it); each LLD is one intent component
- ✓ Granularity — two clean leaves, one per component, with a 1:1 HLD↔LLD mapping
- ⚠ Coherence — the pickup-notices LLD and its EARS disagree on when a lapsed hold closes
- ⚠ Tenet cascade — branch-local allocation cuts across the "waiting is honored in sequence" tenet, unrecorded
- ⚠ Configuration — the `## LID` block exists but carries no LID directives, and the design docs have no `parent:`/`prefix:` pointers
- ⚠ Arrow completeness — no tests, no code, no `@spec` linkage anywhere; all 13 specs are marked implemented

**Headline:** The intent layer here is unusually clean — a lean HLD with real tie-breaker tenets, two well-scoped LLDs with genuine cost-accepting decision rows, and EARS that scopes its conditions properly; the fastest wins are configuration reconciliation (`/update-lid`) and resolving the two places where the design layer and the specs describe different behavior.

### Findings (12 total · 4 high · 6 medium · 2 low)

- **F1 (high):** `CLAUDE.md` carries a `## LID` block (Mode: Full, Version: 1.4.0) but no LID directives — nothing points an agent at the workflow · *modes are declared, not inferred* (declarations live in the instruction file; an unread directive is an unread default) — run `/update-lid` to append the directive block.
- **F2 (high):** All 13 specs are marked `[x]`, which means *code and tests exist*, yet the repository contains no code and no tests — either the implementation lives outside this repo or the markers overstate reality · *intent leads; code is compiled output* (code is the compiled result; the arrow's promise is that the compile is visible) and *coherence is adjacency* (each level must agree with the one above it).
- **F3 (high):** `pickup-notices-design.md:11` says a lapsed hold *closes and the copy is re-run through allocation at lapse*, while `PICKUP-004` (lapse → pull list only) and `PICKUP-005` (staff scan → close, delete, reallocate) put closure at the staff scan — the two levels disagree about when the record is deleted, which is exactly what the "hold history is not kept" tenet hangs on · *coherence is adjacency* (a seam two agents would read differently).
- **F4 (high):** `hold-allocation-design.md:11` allocates to the scanning branch's holds first, so a *later*-placed local hold beats an older county-wide one — that lengthens the earlier patron's wait, which the tenet "nobody's wait is lengthened by a patron who asked after them" forbids outright · *tenets capture forward-looking preference* (tenets are the tie-breakers a future session leans on; a mechanism that works against one needs either a change, a recorded exception naming the tenet, or a revised tenet).
- **F5 (medium):** That branch-local preference has no row in *Decisions & Alternatives* at all — it survives as prose ("keeps most copies off the courier van, which runs once a day"), and a cold reader would both question it and want to reverse it · *docs carry current intent* (decision capture — a live choice needs a record of what was given up).
- **F6 (medium):** Neither design doc carries `parent:`/`prefix:` frontmatter, which 1.4.0 conventions require — the design tree isn't walkable upward, and the ID→owner bridge (`HOLDALLOC-*`, `PICKUP-*`) is only guessable from the ID string · *specs are grep-anchored linkage* (the prefix is the authoritative bridge; `prefix:` frontmatter plus the overlay's index make it explicit) — `/update-lid` backfills these.
- **F7 (medium):** LLD behaviors with no EARS anywhere: cancelling a hold that has no copy in flight, cancelling a hold whose copy is already on the holds shelf, what happens to an allocated copy when its hold closes, and the patron's contact-channel capture at signup · *effective intent-tree alignment* (a behavior with no spec drifts silently, because there is nothing to test against).
- **F8 (medium):** The HLD has no non-goals, no target users, and no key design decisions section, so project-wide choices (e.g. hold-history deletion, single-notice policy) live only as LLD prose and rows · *HLD is architecture and rationale* (the HLD carries the project-global *why*).
- **F9 (medium):** A copy routed to another branch rides a once-daily courier, so that patron's "ready" notice arrives ~a day later, not within Goal 1's four business hours — the courier cadence appears only as an aside in the LLD, and no row records the cost · *tenets capture forward-looking preference* (goal cascade — name the goal, the mechanism, and the condition).
- **F10 (medium):** The daily morning pull list is a *routine* staff task, against the tenet "Routine steps are automated"; the expiry row explains the physical constraint but doesn't name the tenet traded · *tenets capture forward-looking preference* (a recorded exception names the tenet, the mechanism, and why).
- **F11 (low):** Two tenets are phrased as settled facts rather than leans — "Hold history is not kept" (a prohibition) and "Routine steps are automated" (bundles a lean with a mechanism statement) · *tenets capture forward-looking preference* (a tenet is a one-line tie-breaker with a defensible opposite).
- **F12 (low):** No `docs/arrows/` overlay, so there are no arrow-segment coverage tables or cascade markers to read — with two components that's fine; when a third lands, the overlay is what makes cascade health visible · *intent attaches at the lowest node that dominates it* (the overlay's index is where segment boundaries and staleness become enumerable).

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both `-design.md` LLDs, both `-specs.md` files — the entire repository is six documents
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (all `[x]`), 6 Decisions & Alternatives rows, 4 HLD tenets, 2 HLD goals
- Code and tests: none present — 0 `@spec` annotations, so linkage was audited at the EARS boundary only and no entry-point placement could be sampled
- Overlay: `docs/arrows/` is not installed, so `index.yaml` and arrow docs were not in scope and structural enumerations were not attempted (that is `/arrow-maintenance`'s job, not the coach's)
- Cascade evidence: the repo has a single commit, so there is no cross-segment cascade history to sample

### Defaults taken (this run was non-interactive)
- Dispatched to a **full review**: the instruction file lacks LID directives, but the project is clearly LID-shaped (HLD + LLDs + specs), so I coached rather than bouncing you to `/update-lid`.
- **No files were changed** — the coach is advisory by design; findings are surfaced here for you to apply, via `/update-lid` for F1/F6 and directly for the rest.
- Where the skill would have asked, I took its stated default: Full mode as declared, no scope declaration invented, and no report persisted to disk (say the word and I'll write it out).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.