Written and linked at `docs/intent/record-store/decisions/whole-visit-revisions.md` (referenced from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`), covering:

- **Weighted criteria** tied to the HLD tenets (preservation of coupled scientific intent, operational/maintenance simplicity, coordinator review volume, and offline client/payload footprint).
- **Both options in the domain**, including why field-aware three-way merge remains a credible alternative when concurrent edits are mostly independent housekeeping corrections and how it trades a smaller review queue against maintained merge rules and silent cross-field semantic risk.
- **Selection and downstream accommodations** for `tablet-sync` (`base_revision_id` persistence, submission envelope, and fast-forward vs. queued-for-review sync states) and `review-export` (excluding `unresolved` visits from CSV export, whole-visit revision comparison, and submitting `contributing_submission_ids` on resolution).

Before moving to **Phase 3 (EARS specs in `record-store-specs.md`)**, please let me know:
1. Which of the **13 LLD-level edge-case probe items** from the previous message you want fixed in `record-store-design.md` now vs. deferred to Open Questions.
2. Whether `record-store-design.md` and `decisions/whole-visit-revisions.md` are approved to proceed to Phase 3.