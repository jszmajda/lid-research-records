The decision doc is at `docs/intent/record-store/decisions/concurrent-edit-policy.md` and linked from the LLD.

The doc covers:

- **Why field-aware merge stays worth understanding**: Option B gets its strongest honest representation — it genuinely solves the review-workload problem and handles the common case (unrelated concurrent edits) without touching a coordinator. The analysis shows where it is strong before showing where it fails.

- **What breaks it**: the scientific correctness criterion. Merge rules operate on field names and types, not on scientific relationships. A taxon change from one worker combined with a cover estimate from another produces a record that no worker submitted and no rule can flag as inconsistent.

- **What downstream work must accommodate**: the Selection section's obligations are explicit. Tablet-sync carries the base revision ID and must surface unresolved status to workers. Review-export needs a side-by-side comparison view, a withheld-visit indicator, and a coordinator queue that clears before the Friday export.

Ready to move on to Phase 3 (EARS specs) whenever you'd like.