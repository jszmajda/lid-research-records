Created [whole-visit-revisions.md](docs/intent/record-store/decisions/whole-visit-revisions.md) and linked it from the record-store design’s Decisions & Alternatives table.

It records:
- Why scientific coherence and lower merge-rule maintenance outweigh the larger review queue.
- The strongest case for field-aware merging, including conservative grouping rules, reduced review work, and better Friday export availability.
- What evidence could justify reconsidering that alternative.
- Tablet obligations for base revision IDs, complete snapshots, durable retries, and distinguishing acceptance from current state.
- Review/export obligations for whole-revision comparisons, version-checked resolution, provenance, and excluding unresolved visits.

`git diff --check` passed.

Please review the decision document. Does it capture your reasoning? The record-store design questions from the previous review remain open before the EARS update.