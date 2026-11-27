The full decision record is now at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design. It documents:

- Why whole-visit revisions best preserve scientific coherence.
- The strongest case for field-aware merging and conditions that could justify reconsidering it.
- The accepted cost of a larger coordinator review queue.
- Tablet-sync obligations for base revision IDs, complete payloads, idempotency, and review outcomes.
- Review-export obligations for whole-revision comparison, atomic resolution, provenance, and excluding unresolved visits from CSV exports.

One Phase 2 choice remains: if two tablets independently submit a new visit with the same client-generated visit UUID and no base revision, should the second submission be:

1. Preserved as competing review work, consistent with retaining submitted edits.
2. Rejected as an identity collision, requiring tablet-sync to assign a new visit UUID or deliberately resubmit against the existing visit.

Which behavior should the record-store design specify?