The decision doc is written at `docs/intent/record-store/decisions/concurrency-policy.md`. I took your request as choosing option (a), so the doc is a standalone decision record. It is not linked from the record-store LLD yet, because that link belongs in the Phase 2 LLD draft.

The doc covers:
- **Context:** why the policy is needed, and what depends on it. Tablet-sync and review-export cannot size their logic until it is fixed.
- **Criteria:** each one is tied to a tenet or goal from the HLD. The major criteria are keeping the export explainable, not combining related edits silently, and coordinator review load.
- **Whole-visit revisions:** how it works, with a worked example, and how it scores on each criterion.
- **Field-aware three-way merge:** the alternative, with its own example and scores. It is weak on silent combination and on maintained merge rules, and it is strong on review load.
- **Selection:** whole-visit revisions. The cost is more review work, which I recorded as an accepted cost against the "two coordinators" tenet.
- **Downstream obligations:**
  - *Tablet-sync:* each submission carries its base revision ID and an idempotency key. The tablet keeps the base ID for each local draft and shows pending competing revisions without overwriting the local draft.
  - *Review-export:* the coordinator interface needs a side-by-side comparison of competing revisions. Visits with unresolved competing revisions are excluded from the CSV. Each exported visit cites its revision ID.
- **What would reverse it:** review queue counts from real coordinator data showing that most conflicts involve fields that don't interact, plus merge rules a coordinator has reviewed for each scientifically related field group.

Still open from my last message:
1. Approve or change the HLD State cell for record-store. The proposed text is "Drafted; whole-visit revisions selected; contract pending."
2. Confirm the definition of "concurrent." The proposed reading is that an edit is concurrent when its starting revision is no longer the visit's current revision when it arrives.

Once you confirm those, I'll draft the record-store LLD and its EARS specs (Phases 2 and 3). The LLD will link this decision doc, and I'll stop there for your review.