Decision doc written at `docs/intent/record-store/decisions/whole-visit-revisions.md`, and linked from the LLD's Decisions & Alternatives row.

It records:
- **Why field-aware merge stays credible:** lower review volume, more visits exportable, and smaller submissions; it is rejected because disjoint field names do not imply scientific independence, and maintained merge rules can silently combine related edits.
- **The deciding asymmetry:** a larger review queue is visible and recoverable before export; a wrongly combined scientific observation is not.
- **What would reopen it:** measured queue volume that exceeds coordinator capacity, or a rule set demonstrated to preserve scientifically related edits.
- **Tablet-sync accommodations:** keep current/base revision IDs with drafts, send whole payloads, surface "accepted as competing" as queued for review, show unresolved visits without treating the current revision as final, re-fetch after resolution, never base on a competing revision, and reuse idempotency keys. No base snapshots or field-merge state.
- **Review-export accommodations:** compare whole revisions, hold unresolved visits out of the CSV, allow field diffs only for display, record the resolution and contributing submission IDs, and use submission history for provenance. No field-by-field selection.

I also corrected the LLD's definition of "current revision" so a fast-forward submission counts as the latest uncontested revision — the first of two concurrent edits can be current while the second is competing.

The doc and LLD are ready for your review. On approval, I will proceed to the EARS cascade.