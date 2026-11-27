# /lid-coach — Shelfwise

## Executive summary

**Posture:** *Bootstrapping — arrow well-shaped through specs; tests and code not yet in place.*

**Scorecard**
- ✓ HLD discipline — architecture-level doc, no implementation detail bleeding upstream
- ✓ LLD granularity — two focused components, clean separation
- ✓ Decision capture — every Decisions & Alternatives row names the rejected alternative and the accepted cost
- ⚠ Configuration — the instruction file has a mode marker but not a full LID directive block
- ⚠ Arrow completeness — HLD → LLDs → specs are in place; tests and code haven't been reached yet
- ⚠ Spec coverage — one referenced behavior (hold cancellation) has no spec

**Headline:** The design spine is clean and coherent — a small HLD with real tenets, two LLDs whose scopes don't overlap, and specs that read as unambiguous behavior. The fastest wins are reconciling the instruction file with `/update-lid`, closing the one spec gap around cancellation, and — when you're ready — walking the arrow through tests and code so the intent you've captured has verifiable downstream levels.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block declares Mode and Version but carries no linked-intent-dev directive block — the instruction that tells an agent to actually follow LID · *modes are declared, not inferred* (declaration lives in the instruction file, not in convention)
- **F2 (high):** hold cancellation is referenced in `hold-allocation-design.md` and in HOLDALLOC-007 but has no spec of its own — a real user event with no captured intent · *effective intent-tree alignment* (specs and LLD behaviors must trace to each other in both directions)
- **F3 (high):** every spec is marked `[x]` but no tests or code exist in the repo — either the markers are aspirational or the arrow was truncated before the compiled-output phases · *intent leads; code is compiled output*, *tests before code*
- **F4 (medium):** the HLD has Goals but no Non-goals — cold readers can't tell what's deliberately out of scope · *HLD is architecture and rationale* (Non-goals is a canonical HLD section)
- **F5 (medium):** the active-hold transit path — copy arrives at destination branch and lands on the holds shelf — is implicit; only the cancelled-on-arrival path (HOLDALLOC-007) has a spec, and PICKUP-001 assumes the shelf-scan happens without saying who triggers it in the transit case · *LLDs close enough of the solution space*
- **F6 (low):** Tenet 4 ("Hold history is not kept") reads as an already-implemented policy — the specs already delete records — rather than a forward-looking tie-breaker for future ambiguity · *tenets capture forward-looking preference*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/hold-allocation-design.md`, `docs/intent/hold-allocation/hold-allocation-specs.md`, `docs/intent/pickup-notices/pickup-notices-design.md`, `docs/intent/pickup-notices/pickup-notices-specs.md`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (7 HOLDALLOC + 6 PICKUP)
- Arrow-path sampled: 0 end-to-end paths — the arrow terminates at specs in this project (no test or code files present to sample from)
- No `docs/arrows/` overlay present; no arrow index to consult
- Decisions-table sweep: 7 rows across both LLDs — all pass the cold-reader test (rejected alternative + accepted cost stated)

## Worth a second look

Models in my class are known to miss cases where a leaf design contradicts the project's own tenets, and to under-weigh the difference between a real forward-looking tenet and a policy already fully specified. Please sanity-check the Shelfwise tenets against the two LLDs yourself — especially Tenet 4 (F6) and whether the transit gap in F5 quietly cuts against Tenet 1 ("waiting is honored in sequence").

## Offer to help

Want me to walk through the findings in detail, focus on a priority band, or work through any single finding together? You can also pick one item — e.g., the cancellation spec (F2) or the transit gap (F5) — and we can shape the fix directly.

If you have broader questions about using LID for Shelfwise — how to grow past two components, when to introduce a sub-HLD, where PRDs or ops runbooks might fit alongside the arrow, what to do when a segment starts to feel too dense — I can help with those too.