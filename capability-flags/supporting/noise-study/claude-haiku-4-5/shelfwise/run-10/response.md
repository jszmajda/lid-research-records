---

## LID Coach Review — Shelfwise

**Posture:** Healthy, bootstrapping. The arrow is well-structured and clearly written; the project is ready to move into implementation with one small spec gap to close.

**Scorecard**
- ✓ **Tenets** — four defensible tie-breakers that guide intent; align with design choices
- ✓ **Intent clarity** — HLD and LLDs read fresh; all choices have clear trade-offs recorded
- ✓ **Granularity** — two intent components, two LLDs, no lumping or scattering
- ✓ **Spec alignment** — all specs trace to their LLDs trace to HLD
- ⚠ **Spec coverage** — one edge case in hold lifecycle is unspecified

**Headline:** The design is mature and ready for implementation; the fast next step is closing one spec gap around hold cancellation, then building tests and code to the existing specs.

**Findings (1 total · 1 medium)**

- **F1 (medium):** Hold allocation lacks spec for cancellation at desk · *LLDs close enough of the solution space*

---

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/hold-allocation/, docs/intent/pickup-notices/
- Enumerated: 1 HLD, 2 LLDs, 13 total specs
- Cold-read pass: all docs for implicit context and accumulation patterns

---

**F1 — Hold allocation spec gap.** The hold allocation design covers what happens when a hold is cancelled while its copy is in-transit: HOLDALLOC-007 says re-run allocation on arrival. But the design doesn't specify what happens if a hold is cancelled while its copy is allocated at the desk (after check-in, before shelf scanning), or if the hold lifecycle involves the patron cancelling after the copy lands on the shelf. A cold reader would wonder: does Shelfwise even receive cancellation events, or does the catalog system handle cancellation independently? Under *LLDs close enough of the solution space* — a good LLD leaves the solution space tight enough that two reasonable agents would build compatible systems — this edge case is ambiguous. The fix is to add specs for both scenarios. One option is to document the hold lifetime scope in the design's Context section (e.g., "Holds are placed in the catalog system; Shelfwise reacts to check-in events and receives cancellation notifications for copies in transit, but not at desk or on shelf, which the catalog handles directly"), then add specs for the cases Shelfwise *does* handle. Another is to spec all three states: allocated-at-desk, in-transit, and on-shelf. Try drafting a spec: "When a hold is cancelled while its copy is allocated at desk, the system shall [reallocate the copy / return it for reshelving / ...], then add it to the story for hold-allocation-design.md Decisions & Alternatives if it's a choice with trade-offs.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.