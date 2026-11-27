Created [the concurrency decision document](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store design.

It records:
- Why preserving whole scientific observations outweighs a larger review queue.
- The strongest case for field-aware merging, including review throughput and smaller submissions.
- What would justify reconsidering that alternative.
- Tablet obligations for base revision IDs, complete snapshots, retries, and pending-review status.
- Review/export obligations for revision comparison, provenance, stale-review handling, and excluding unresolved visits from CSV.

`git diff --check` passed.

To finish the resolution contract, one decision comes next: **may coordinators only select an existing whole revision, or also author a complete replacement?** Selection-only keeps review simpler; a replacement lets them preserve valid corrections from both submissions through explicit human judgment, but requires editing, validation, and replacement provenance.