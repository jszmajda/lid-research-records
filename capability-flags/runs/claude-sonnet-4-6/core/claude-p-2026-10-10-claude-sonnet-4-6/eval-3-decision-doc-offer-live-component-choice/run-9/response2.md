Here is the final Phase 2 artifact — **`docs/intent/record-store/record-store-design.md`** — for your review before I write specs.

---

## `docs/intent/record-store/record-store-design.md`

---
parent: high-level-design  
prefix: REC

---

### Context and Design Philosophy

Whole-visit revisions. Each submission is a complete snapshot naming the server revision the worker started from. Competing submissions are preserved; the record store never merges fields automatically.

---

### Submission Envelope

Five fields: visit ID, base revision ID (`null` for first-ever), idempotency key (globally unique UUID per attempt, not scoped per visit), **submission type** (`worker` or `coordinator`), submitting identity, and full visit payload.

---

### Visit State Model

Three states — **clean**, **unresolved**, **resolved** — with explicit transitions for all paths including post-resolution worker submissions (canonical revision becomes the new clean tip, so normal work resumes from there).

---

### Submission and Retrieval

Current-state for unresolved visits returns **competing revision IDs only, no payload**. The alternative — returning the most recently accepted competing revision as a preview — was documented and rejected: it misrepresents authoritative state and may anchor coordinator judgment toward whichever revision arrived last.

---

### Resolution Operations

Two coordinator operations (both `coordinator`-type, bypassing worker competition detection):
- **Select**: pick one competing revision as canonical
- **Synthesize**: submit a new combined revision superseding all competitors

The distinct submission type was chosen over a sentinel base value because it expresses the semantic difference throughout the data model; a sentinel conflates null-base meaning and forces every competition-detection caller to special-case it.

---

### Decisions & Alternatives

All five resolved choices recorded with alternatives and rationale, including whole-visit vs. field-aware merge and the two coordinator-type options.

---

### Open Questions

Five questions resolved in the LLD; two deferred (late submission to an already-resolved visit; competing revision cap/alert). The late-submission question needs an answer before tablet-sync and review-export can be fully designed.

---

### Downstream Cascade Obligations

Explicit lists of what tablet-sync and review-export must accommodate — base revision tracking, no-payload handling for unresolved visits, coordinator-only synthesis, export exclusion, resolution provenance in exports.

---

Does this read correctly? Any changes before I move to Phase 3 and write the specs?