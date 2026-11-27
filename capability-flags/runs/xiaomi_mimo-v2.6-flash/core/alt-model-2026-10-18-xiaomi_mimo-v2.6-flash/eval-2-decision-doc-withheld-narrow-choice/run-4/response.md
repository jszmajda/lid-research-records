**Phase 1 — HLD check: complete. STOP for your review.**

**Coherence pre-flight (previews segment):**
- EARS ↔ LLD: PREVIEW-001…005 all trace to the current LLD. No spec claims an eviction policy, so nothing contradicts the 2Q choice yet — but no spec will cover it either until Phase 3.
- Tests ↔ EARS: no tests exist yet (no code in the repo) — expected at this stage.
- LLD ↔ HLD: both said the eviction policy was open — mutually coherent, both stale against your decision. The HLD is now updated; the LLD is Phase 2's work.

**Phase 1 result:** The HLD exists and covers the domain. The three options were sketched last session and you've selected 2Q, so no new option sketch is needed. The choice's effects stay inside the preview worker (review API and render queue untouched), so it will land as a Decisions & Alternatives **row** in the previews LLD, not a standalone decision doc.

**HLD changes (`docs/high-level-design.md`):**
- Architecture: "…a private 12 GiB cache. Its eviction policy remains open." → "…a private 12 GiB cache with 2Q eviction."
- Goals: "…through the same interface for every eviction policy." → "…through the same interface regardless of cache state."

No new tenets surface from closing this decision.

**Approve to proceed to Phase 2?** There I'll finish the previews LLD — replace the open-candidates paragraph with the 2Q design (first-use vs. reused queues, the size split, admission/eviction flow), record the Decisions row, and run the LLD-level edge-case probe; you'll triage any gaps at that stop. Numbered feedback welcome.