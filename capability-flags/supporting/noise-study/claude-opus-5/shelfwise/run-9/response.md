# LID Coach — Shelfwise

## Executive summary

**Posture:** Intent layer is clean and well-shaped; the arrow's bottom half isn't built yet, and the HLD and its leaves currently disagree about fairness.

**Scorecard**
- ✓ **Doc hygiene** — no history residue, no obsolete markers; every doc reads as current intent
- ✓ **LLD granularity** — two leaves matching the HLD's two components, no silent overlap
- ✗ **Arrow completeness** — no tests or code anywhere, though all 13 specs are marked `[x]`
- ⚠ **Design/tenet coherence** — branch-first allocation runs against the "waiting is honored in sequence" tenet
- ⚠ **Decision capture** — the two choices a cold reader would most question have no recorded trade
- ⚠ **Configuration** — the `## LID` block is present but the LID directive block isn't

**Headline:** The intent layer is genuinely good — tight EARS specs with real WHEN clauses, two Decisions & Alternatives tables that mostly name their costs, and an HLD with actual tenets rather than platitudes. The single most valuable next step is resolving whether branch-first allocation or sequence-fairness wins, and recording that trade in `hold-allocation-design.md` before any code compiles the current ambiguity into place.

## Findings (15 total · 5 high · 8 medium · 2 low)

- **F1 (high):** `CLAUDE.md` carries the `## LID` mode/version block but no LID directive block — nothing names linked-intent-dev · *modes are declared, not inferred* — the foundation should be visible, not inferred
- **F2 (high):** All 13 specs are marked `[x]` but the repo has no tests and no code — the arrow stops at EARS · *canonical arrow shape* + *tests before code* — tests preload the use of the system before implementation exists
- **F3 (high):** Branch-first allocation (HOLDALLOC-003/004) lets a later local patron receive a copy ahead of an earlier county-wide one, against Tenet 1 "waiting is honored in sequence" · *coherence is adjacency* — each level agrees with the one above it
- **F4 (high):** The branch-priority rule — the most consequential choice in hold allocation — has no Decisions & Alternatives row naming the rejected strict-FIFO alternative or the fairness cost accepted · *decision capture* — a cold reader should be able to reconstruct the choice
- **F5 (high):** Goals 1 and 2 are unmeasurable as designed — PICKUP-003/005 delete the hold record at close, taking the check-in and notification timestamps with it · *docs carry current intent, read cold* — the measurement plan lives only off-page
- **F6 (medium):** HOLDALLOC-004's condition is also true when a title has zero open holds, overlapping HOLDALLOC-005 — an agent grepping 004 alone would print a transit slip for nobody · *scope disambiguation* — a spec found out of context must still be unambiguous
- **F7 (medium):** Hold cancellation is relied on by HOLDALLOC-007 but never designed or spec'd; cancellation while the copy sits on a holds shelf is undefined · *LLDs close enough of the solution space*
- **F8 (medium):** Arrival of an in-transit copy whose hold is still live has no spec, and the in-transit state itself is used without any spec establishing it · *effective intent-tree alignment* — LLD behaviors with no specs are unnamed intent
- **F9 (medium):** "Re-run allocation as a check-in at branch B" is invoked from both segments, but PICKUP-005 specifies hold-allocation's behavior from inside pickup-notices · *intent attaches at the lowest node that dominates it* — shared substance should rise to the shared parent
- **F10 (medium):** The automated-dialer channel is under-specified — PICKUP-006's failure examples cover only email and SMS, leaving "failed delivery" for a voice call open to interpretation · *LLDs close enough of the solution space*
- **F11 (medium):** Tenets 3 and 4 are phrased as rules already carried by PICKUP-002/003/005 rather than as leans, and the list is unordered though several trade against the stated Goals · *tenets capture forward-looking preference* — a tenet is a tie-breaker, not a triggered rule
- **F12 (medium):** The HLD has no non-goals, no target users, and no Key Design Decisions section; "Goals" holds success metrics · *HLD is architecture and rationale*
- **F13 (medium):** The no-history decision (Tenet 4) has no Decisions row naming what was given up — auditability, metrics, patron dispute resolution · *decision capture*
- **F14 (low):** Neither spec file carries `prefix:` frontmatter, so `HOLDALLOC` and `PICKUP` resolve to their leaves only by inference · *specs are grep-anchored linkage*
- **F15 (low):** "Oldest timestamp" has no tie-break when two holds share a placement timestamp · *LLDs close enough of the solution space*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (both design docs, both spec files) — the repo's entire contents
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs (7 HOLDALLOC, 6 PICKUP), 7 Decisions & Alternatives rows, 4 tenets
- Arrow overlay: `docs/arrows/` not present — no `index.yaml` to guide segment selection
- Linkage metric: 0 `@spec` references repo-wide; 0 test files, 0 source files
- Arrow-path sampled: both segments walked end-to-end as far as they go (HLD component → LLD → spec → ∅); below the 15-LLD / 200-file thresholds, so no further sampling applied
- Passes run: dimension review across all 18 dimensions, cold-read pass through all five LID docs, and the mechanical Decisions-table sweep over all 7 rows (all 7 pass the cold-reader test; the findings above are about rows that are *absent*)

## Worth a second look

Models in my class are known to miss designs that contradict the project's own tenets — F3 is one instance I did catch, but please check the rest of both leaf designs against your four HLD tenets yourself, particularly Tenet 2 ("staff attention goes to exceptions") against the morning-pull-list and exceptions-list flows. One note on this section: `references/capability-flags.md` sits outside this session's readable paths, so I could not place myself against the flag list and applied the skill's stated default of treating the flags as applying.

## Where to go next

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? F3 and F4 are a natural pair to start with since they share a root, and F1 is a quick `/update-lid` away.

If you have broader questions about using LID on Shelfwise — how the circulation-system boundary should be modeled, where a PRD for the library board would fit, whether Full mode still fits once code lands, or how to split hold allocation if transit routing grows into its own concern — I'm happy to think through those too.