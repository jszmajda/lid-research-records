Written: `docs/intent/record-store/decisions/concurrent-edit-resolution.md`, linked from the LLD's Decisions & Alternatives table.

It covers, per your ask:
- **Why merge remains credible**: the conditions that would flip the judgment — corrections proving mostly disjoint, review volume threatening the Friday export, merge rules bounded to enumerated field couplings with science-partner sign-off, or required approval of combined records becoming acceptable.
- **Tablet-sync accommodations**: base revision IDs and complete payloads; displaying the acceptance outcome so a review-bound edit doesn't feel lost; the open decision on showing pending competing revisions; idempotent retry.
- **Review-export accommodations**: whole-revision comparison (not field merges); unresolved visits held out of the CSV with the queue including unrelated-field competitions by design; the coordinator's combined-correction path as a standard follow-up submission.
- **Forecloses**: field-level provenance, automatic export readiness, and merge-as-configuration.

Still pending from my last message: triage of the nine probe gaps (first-submission race, resolution atomicity, re-opened unresolved state, nonexistent base, rejected-submission retention, idempotency-key scope, revision-ID uniqueness, resolution input identity, arrival-order tension) — and after that, the intent-narrowing audit over the new specs before any tests or code.