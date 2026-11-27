**LID Coach — Shelfwise**

## Executive summary

**Posture:** Strong intent layer, pre-implementation — the arrow is well-authored down to EARS and stops there; the drift worth attention is tenet-to-design lean, not doc hygiene.

**Scorecard**
- ✓ **HLD discipline** — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ✓ **Mutation hygiene** — both design docs read as authored fresh today; no changelogs, no `[obsolete]` residue, no `[inferred]` backlog
- ⚠ **Tenet cascade** — branch-local allocation and the transit path lean against stated tenets/goals with nothing on the record
- ⚠ **Decision capture** — three solid Decisions tables, but the sharpest choice in the system has no row
- ⚠ **Configuration** — the `## LID` block declares Mode and Version but carries no LID directives
- ✗ **Arrow completeness** — every spec is marked `[x]`, yet no tests or code exist in the repo

**Headline:** Two components, two design docs, two spec files, 13 EARS specs with clean WHEN-clauses and real Decisions tables — this is a genuinely well-built intent layer for a six-branch holds system, and the HLD's tenets are mostly real tie-breakers rather than platitudes. The fastest wins are recording the branch-local allocation decision (and reconciling it with the sequencing tenet) and closing the two spec gaps at copy arrival and hold cancellation.

## Findings (12 total · 5 high · 5 medium · 2 low)

- **F1 (high):** Branch-local priority in `HOLDALLOC-003` lengthens an earlier county-wide patron's wait, against the tenet *"Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them"* · *tenet cascade* — leaf mechanisms should lean the way the HLD says to lean, or record the exception
- **F2 (high):** That same branch-local preference (`hold-allocation-design.md:11`, "This keeps most copies off the courier van") has no Decisions & Alternatives row naming the alternative or the accepted cost · *decision capture* — a cold reader would question or try to reverse this one
- **F3 (high):** All 13 specs carry `[x]` complete markers while the repo holds no tests and no code · *coherence is adjacency* and *tests before code* — adjacent levels can't agree when two phases are absent
- **F4 (high):** Nothing specifies what happens when an in-transit copy arrives for a still-open hold — `HOLDALLOC-004` prints a transit slip, `PICKUP-001` starts on a holds-shelf scan, and only the *cancelled*-hold arrival (`HOLDALLOC-007`) is covered · *effective intent-tree alignment* — described behavior with no spec drifts silently
- **F5 (high):** The instruction file's `## LID` block has `- Mode: Full` and `- Version: 1.4.0` but no `linked-intent-dev` directives, so tests-first and `@spec` conventions aren't on the page for the sessions that will write the code · *modes are declared, not inferred* — recommend `/update-lid`
- **F6 (medium):** The transit path defeats Goal 1 (median notification under 4 business hours) whenever the once-a-day courier is involved, and no Decisions row records that trade the way the expiry row does · *tenet cascade*
- **F7 (medium):** Hold cancellation is referenced (`hold-allocation-design.md:13`, `HOLDALLOC-007`) but never specified, and nothing deletes a cancelled hold's record — against the tenet *"Hold history is not kept"* · *LLDs close enough of the solution space*
- **F8 (medium):** Tenet 4 *"Hold history is not kept"* is phrased as a triggered rule already fixed by `PICKUP-003`/`PICKUP-005`, not a lean a future session could apply to an uncovered choice · *tenets capture forward-looking preference* — a tenet's job is the decision no spec anticipated
- **F9 (medium):** The four tenets are an unordered list though they can conflict in practice (sequencing vs. courier efficiency; hear-once vs. Goal 2's expiry target) · *tenets capture forward-looking preference*
- **F10 (medium):** Spec files carry no `prefix:` frontmatter, and the prefixes (`HOLDALLOC`, `PICKUP`) diverge from the node names (`hold-allocation`, `pickup-notices`), so the leaf path has to be inferred · *specs are grep-anchored linkage* — the leaf prefix is the cascade boundary and should be resolvable, not guessed
- **F11 (low):** "No reminder follows." (`pickup-notices-design.md:9`) reads as a defensive aside in body prose where the Decisions row already carries the rejected day-5 reminder · *docs carry current intent* — rejected alternatives live in the table, not in asides
- **F12 (low):** Decisions rows cite "Goal 1" and "Goal 2" by list position; naming the goals would survive a reordering of the HLD's numbered list · *semantic legibility as cheap linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` — the entire repository is 6 files
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs, 3 Decisions & Alternatives tables (10 rows total), 4 tenets, 2 goals
- Arrow-path sampled: both segments walked end-to-end (HLD Components → design doc → spec file → tests → code); both terminate at the spec level — 0 test files, 0 source files, 0 `@spec` annotations found anywhere in the tree
- Cold-read pass: all 5 LID docs read without conversation context; residue screen for change-narration, `[obsolete]`, and `[inferred]` markers returned clean
- Not present, so not reviewed: `docs/arrows/` overlay (no structural audit available — `/arrow-maintenance` isn't applicable yet)

## Next steps

Want me to walk through the findings in detail, focus on a theme (the tenet-cascade cluster in F1/F6/F8/F9 is the most connected thread) or a priority level, or work through specific items together? Pick any single finding and I'll go deep on it — including what a Decisions row for the branch-local choice could look like.

If you have broader questions about using LID on Shelfwise — when to add the arrow overlay, how the tests-first phase works for an event-driven system like this, or how to sequence spec authoring against implementation now that the intent layer is ahead of the code — I can help with those too.