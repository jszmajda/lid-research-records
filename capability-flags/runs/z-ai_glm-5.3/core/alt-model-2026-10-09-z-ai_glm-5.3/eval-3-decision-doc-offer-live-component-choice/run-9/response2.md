Decision doc written: `docs/intent/record-store/decisions/whole-visit-revisions.md`.

It gives the merge option its strongest case (smallest review queue, delta submissions), scores both against five weighted criteria tied to your tenets, and records the revisit trigger — measured review volume exceeding the two-coordinator cadence, especially if queue items are mostly unrelated-field divergences. The downstream obligations you asked for are spelled out in Selection: tablet-sync must retain current revision IDs across restarts/disconnection, send full payloads against that base, and explain divergent outcomes including pending competing revisions to workers; review-export must build a whole-revision comparison view, hold unresolved visits out of the CSV, and size its queue for divergence-only volume. The LLD's Decisions row now links to the doc.

Still open from the previous stop:

1. May I update the one stale sentence in `site-catalog-design.md` ("tablet-sync's visit submission and reconciliation behavior remains pending that choice")? Cross-segment, so I'd rather ask than touch it.
2. The three deferred open questions — identical-content divergent submissions, re-opening withdrawn revisions, unresolved-listing pagination — need your triage whenever you're ready.