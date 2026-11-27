Added [Concurrent Visit Edits](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store’s Decisions & Alternatives table.

It records:
- Why whole-visit scientific integrity outweighs a smaller review queue.
- The strongest case for field-aware merging, including reduced coordinator workload and faster export readiness.
- Evidence that could justify reconsidering merging later.
- Tablet obligations: complete payloads, base revision IDs, durable retry identity, and explicit pending-review outcomes.
- Review/export obligations: whole-revision comparison, version-checked resolution, provenance, and exclusion of unresolved visits from CSV.

`git diff --check` passed.

For the next design decision: **should coordinators only select an existing complete revision, or also be able to author a new complete visit when neither candidate is correct?**