Wrote `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### What's in `decisions/concurrent-visit-edits.md`
- **Context & Decision Elements:** Frames the offline survey constraints and weighs four criteria (`major`: whole-visit scientific intent/provenance inspectability and operational/maintenance simplicity, tied to the HLD tenets; `moderate`: coordinator review throughput and Friday export readiness; `minor`: offline client storage and submission simplicity).
- **Options in the Domain:**
  - *Whole-Visit Revisions* — immutable full-visit snapshots with `base_revision_id` tracking and coordinator resolution of competing heads.
  - *Field-Aware Three-Way Merge* — structured field-level change merging for scalars, observer lists, and species cover entries, including why it remains attractive when disjoint routine fixes are frequent and how it keeps the Friday review queue smaller.
- **Selection & Downstream Obligations:** Records why whole-visit revisions wins on the two major tenets, when to revisit if disjoint-field review volume overwhelms the two coordinators, and what `tablet-sync` (tracking `base_revision_id`, submitting full payloads with `idempotency_key`, surfacing `needs_review`) and `review-export` (revision comparison view, exact `contributing_revision_ids` resolution with conflict handling, excluding `needs_review` visits from the Friday CSV) must accommodate.

---

**Phase 2 stop:** Let me know if you'd like any changes to `decisions/concurrent-visit-edits.md` or `record-store-design.md`, and how you'd like to triage probe items 1–8 from above (specify now vs. defer) before I move to Phase 3 (`record-store-specs.md`).