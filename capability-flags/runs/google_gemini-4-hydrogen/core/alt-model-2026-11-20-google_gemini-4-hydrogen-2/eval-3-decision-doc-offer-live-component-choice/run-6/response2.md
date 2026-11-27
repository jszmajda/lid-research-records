Wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

It covers:
- **Both options against HLD tenets**: Why whole-visit revisions wins on preventing silent scientific corruption and avoiding rule-maintenance burden, and why field-aware three-way merge remains the alternative to revisit if unrelated-field review volume outgrows what two coordinators can clear before Friday exports.
- **Downstream obligations**:
  - `tablet-sync`: Persist `base_revision_id` per local draft, retain an `idempotency_key` across retries, submit whole-visit payloads, and surface `needs_review` / `accepted_competing` outcomes to field workers.
  - `review-export`: Provide a whole-visit revision comparison view for `needs_review` visits, invoke `resolveVisitReview` with coordinator identity and contributing submission IDs, and exclude `needs_review` visits from the Friday CSV export until resolved.

Before we move to **Phase 3 (EARS spec updates)**, please let me know how you'd like to triage the Phase 2 edge-case questions from the previous message (which ones to specify in `record-store-design.md` now vs. defer), and confirm if we can proceed to Phase 3.