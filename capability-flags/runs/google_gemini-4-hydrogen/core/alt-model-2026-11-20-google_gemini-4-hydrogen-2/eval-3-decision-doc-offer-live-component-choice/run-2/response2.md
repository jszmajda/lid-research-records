I created `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

The decision doc covers:
- **Decision elements**: Scientific integrity of coupled fields, coordinator review workload / Friday export readiness, rule maintenance and operational simplicity, provenance and inspection clarity, and offline tablet state / submission footprint, tied to the HLD tenets.
- **Options in the domain**: Full representation and per-element analysis for both **Whole-visit revisions** and **Field-aware three-way merge**, including why three-way merge would still be considered if review queue volume exceeds two coordinators' capacity before Friday exports.
- **Downstream accommodations**: The specific obligations on `tablet-sync` (`base_revision_id` tracking, surfacing `accepted_competing` outcomes) and `review-export` (excluding `pending_review` visits from the Friday CSV, side-by-side whole-revision comparison, and coordinator-authored resolved revisions).

Before moving to Phase 3 (`record-store-specs.md`), please let me know:
1. Whether the decision doc and `record-store-design.md` look good to approve for Phase 2.
2. How you want to triage the 12 internal edge-case questions from the previous message (which to specify in `record-store-design.md` now vs. defer).