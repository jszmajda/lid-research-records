The full decision record is now at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the record-store design. It documents:

- Why whole-visit revisions were selected.
- Why field-aware three-way merge remains credible if review volume becomes unmanageable.
- The scientific-integrity, workload, maintenance, provenance, and export-readiness tradeoffs.
- Concrete obligations for record-store, tablet-sync, and review-export.

One record-store identity question remains before Phase 2 can close: what must stay fixed under a visit UUID?

1. UUID only: both plot and observation date may be corrected.
2. UUID and plot: observation date may be corrected, but changing plot requires a new visit.
3. UUID, plot, and observation date: either change requires a new visit.