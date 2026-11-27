Phase 1–4 complete for the preview design with 2Q selected.

**Phase 1 – HLD**
Updated `docs/high-level-design.md`:
- Previews node now reads: “Owns rendering, pending jobs, and a private 12 GiB cache with 2Q eviction.”

**Phase 2 – LLD**
Updated `docs/intent/previews/previews-design.md`:
- Private Cache section now specifies 2Q implementation: two private FIFO queues Q1 for first-use and Q2 for reused entries, promotion on second access, eviction prefers Q1, Q1/Q2 share the 12 GiB budget with a configurable size split, all bookkeeping stays private.
- Added Decisions & Alternatives table recording 2Q chosen over LRU and frequency-based eviction with aging, rationale to protect comparison sheets during sequential screenings.
- Open Questions & Future Decisions marks eviction policy resolved 2026-10-16; Q1/Q2 size split value and Q2 growth cap deferred.

**Phase 3 – EARS**
Updated `docs/intent/previews/previews-specs.md`:
- PREVIEW-006: When eviction is required to admit a new preview, the system SHALL select eviction candidates from the first-use queue before selecting from the reused queue.
- PREVIEW-007: When a cached preview is accessed for the second time, the system SHALL promote it to the reused queue.
Existing PREVIEW-001…005 unchanged.

Post-draft consistency: specs cover admission limit, promotion, and eviction preference; API contract unchanged. No contradictions found.

**Phase 4 – Intent-narrowing edge audit**

Gaps to resolve before tests:

1. PREVIEW-006 fallback: If Q1 is empty, does eviction fall through to Q2 or must admission wait? Specify fallback behavior.
2. PREVIEW-007 scope: Does “accessed for the second time” mean a served cached hit only, or does a 202 pending response for a key already in Q1 count as an access? Clarify promotion timing relative to render deduplication.
3. Size split enforcement: Is the Q1/Q2 split a hard cap per queue or a soft target with total 12 GiB budget? Decide whether Q2 may temporarily exceed its split when protecting reused sheets.

Please confirm:
- The HLD, LLD, and specs as drafted above.
- Resolution of the three edge questions above.

On approval I will proceed to Phase 5 tests-first and Phase 6 code for the preview segment.