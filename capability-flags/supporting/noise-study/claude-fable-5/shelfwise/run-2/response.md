**Shelfwise — LID Coach Report** · 2026-09-25

## Executive summary

**Posture: Bootstrapping — the intent layer is genuinely strong; the arrow stops at specs.**

**Scorecard**
- ✓ Mutation hygiene — docs read cold, no history residue or changelog leftovers anywhere
- ✓ HLD discipline — problem, tenets, goals, components; no implementation detail bleeding upstream
- ✓ LLD granularity — one LLD per intent component, matching the HLD's component map exactly
- ⚠ Configuration — the `## LID` mode block is present, but the LID directive block is missing from `CLAUDE.md`
- ⚠ Intent coherence — the branch-first allocation design sits in tension with the "waiting is honored in sequence" tenet
- ✗ Arrow completeness — no tests and no code exist, yet every spec is checked off as done

The design and spec layers are unusually clean for a project this young — tight EARS specs, disciplined Decisions & Alternatives tables, an HLD that stays at altitude. The fastest wins are deciding whether branch-first allocation or the sequence tenet gives way, and reconciling the spec status markers with the (currently absent) test and code phases.

## Findings (7 total · 3 high · 3 medium · 1 low)

- **F1 (high):** All 13 specs are marked `[x]`, but the repo contains no tests, no code, and no `@spec` annotations — the arrow's last two phases are missing while the status markers read as complete · *canonical arrow shape* — the arrow runs HLD → LLDs → EARS → Tests → Code, and a collapsed phase should be deliberate and documented, not drifted into
- **F2 (high):** Branch-first allocation (hold-allocation design; HOLDALLOC-003/004) lets a later hold at the scanning branch jump an older hold elsewhere, contradicting the tenet "nobody's wait is lengthened by a patron who asked after them" · *coherence is adjacency* — each level of the arrow agrees with the one above it, and here the LLD disagrees with its HLD
- **F3 (high):** `CLAUDE.md` carries the `## LID` mode block but no LID directive block — consider `/update-lid` to reconcile · *modes are declared, not inferred* — the instruction file is the foundation every session keys off
- **F4 (medium):** The branch-first-vs-county-wide allocation choice — the biggest decision in the system — has no Decisions & Alternatives row; only the courier-van rationale in design prose, with the rejected alternative (strict county-wide order) and accepted cost (the tenet trade) unrecorded · *decision capture* — a choice a cold reader would question deserves a row they can reconstruct it from
- **F5 (medium):** "Fails to deliver" (PICKUP-006) is defined by example only for email and SMS; whether an unanswered automated-dialer call counts is an open edge an implementer would have to guess · *LLDs close enough of the solution space* — open edges are where intent drift enters
- **F6 (medium):** Hold cancellation is presupposed (HOLDALLOC-007 handles a copy arriving *after* a cancellation) but never itself specified — no spec covers cancelling a hold or deleting its record, though the "hold history is not kept" tenet implies deletion there too · *effective intent-tree alignment* — behavior with no spec is unnamed intent that drifts silently
- **F7 (low):** The tenet "Hold history is not kept" pairs a real privacy lean with a spec-shaped second sentence ("a closed hold's record is deleted") already covered by PICKUP-003/005; consider trimming the tenet to the lean · *tenets capture forward-looking preference* — a tenet is a tie-breaker, not a triggered rule

Note on F2/F4: these are deliberately separate. The design tension is one finding; the missing capture of the decision behind it is another — resolving one doesn't resolve the other. If you decide the branch-first policy stands, the remedy is to soften the tenet's absolute second clause and add the Decisions row; if the tenet stands, HOLDALLOC-003/004 change.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 intent components, 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006), 14 Decisions & Alternatives rows
- Searched for: test files, source code, `@spec` annotations, `docs/arrows/` overlay — none present, so no arrow-path sampling was possible below the spec level
- Cold-read and decisions-table passes ran over all five docs; 13 of 14 decision rows reconstruct cleanly for a cold reader

**Worth a second look:** I could not load the capability-flags reference (it sits outside this session's permitted directories), so per the skill's default I treated its flags as applying to me. The known flag area — missing designs that contradict the project's own tenets — falls squarely in this review; I surfaced one such tension (F2), but please check the leaf designs against your HLD tenets yourself.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.