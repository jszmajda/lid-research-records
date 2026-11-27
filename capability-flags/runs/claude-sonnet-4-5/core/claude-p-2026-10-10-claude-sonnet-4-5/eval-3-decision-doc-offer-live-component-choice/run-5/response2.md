**Phase 2 Complete — Record Store LLD**

I've finished the record-store design with the whole-visit revision approach. Here's what changed:

**Core mechanism**: Server-assigned revision IDs, base revision tracking, competing revisions trigger coordinator review rather than automatic merge.

**Why field-aware merge is still credible**: For projects with high concurrent-edit volume (where whole-visit review would overwhelm coordinators) or structurally guaranteed field independence. This project's low volume (estimated 5-10 conflicts/week) and small coordinator team (2 people) makes explicit review manageable.

**What tablet-sync must build**:
- Base revision ID persistence across app restarts
- Optimistic current-state handling vs. conflict notification to workers
- Idempotency key survival through crashes
- Retry state machine
- Larger submission payloads (whole visits, not deltas)

**What review-export must build**:
- Side-by-side revision comparison with field-level diffs
- Three resolution modes (select existing, author new, defer)
- Export filter excluding unresolved visits
- Coordinator review queue sorted by time/plot
- Resolution audit trail showing who resolved what

**Eight deferred questions** captured as implementation concerns: visit/plot association, stale base handling, resolution validation, mid-resolution races, first-submission races, history endpoint spec, partial resolution semantics, and error responses.

The complete LLD is at `docs/intent/record-store/record-store-design.md`.

Ready to proceed to Phase 3 (EARS specs)?