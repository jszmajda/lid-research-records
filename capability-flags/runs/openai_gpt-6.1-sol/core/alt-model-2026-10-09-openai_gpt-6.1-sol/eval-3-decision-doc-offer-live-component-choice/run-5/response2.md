Created [the concurrency decision document](docs/intent/record-store/decisions/concurrent-visit-revisions.md) and linked it from the record-store design.

It covers:
- Why preserving scientific relationships and avoiding maintained merge rules outweigh reducing review volume.
- The strongest case for field-aware merging, including what evidence could justify reconsidering it.
- Tablet obligations: complete payloads, base revision IDs, durable retries, and distinguishing acceptance from current readiness.
- Review/export obligations: revision comparison, provenance, stale-review protection, and excluding unresolved visits from CSV.
- The tension between simpler software and a larger queue for two coordinators.

The document is consistent with the record-store draft; `git diff --check` passed.

To finish the resolution contract: **should coordinators only select an existing revision intact, or also be able to author a complete corrected visit during review?**