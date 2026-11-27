Created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the record-store design.

It documents:

- The scientific-integrity and provenance reasons for whole-visit revisions.
- The strongest case for field-aware merging, especially coordinator throughput.
- Conditions that could justify reconsidering field-aware merging.
- Tablet obligations: base revision IDs, complete payloads, offline retry state, and conflict outcomes.
- Review/export obligations: whole-revision comparison, complete candidate sets, stale-resolution detection, and exclusion of unresolved visits from CSV.
- The migration and merge-rule safeguards required before changing approaches.

`git diff --check` passes.

Before closing the record-store design, how should timed-out resolutions behave?

1. **Idempotent resolution:** Every resolution has a coordinator-scoped idempotency key. Retrying the identical request returns its original result even if the conflict has already closed. All mutations to one visit commit atomically in a single order.
2. **Fetch and infer:** A timed-out coordinator fetches the visit and determines whether the resolution succeeded from its current state.

I recommend option 1 because option 2 can become ambiguous if another edit arrives immediately after resolution.