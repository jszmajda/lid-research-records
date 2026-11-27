The decision doc is written: `docs/intent/record-store/decisions/concurrent-visit-edits.md`, linked from the LLD's Decisions & Alternatives row.

What it contains:

- **Gate**: automatic combination must not cross scientific relationships — drawn from the HLD's non-goal on inferring scientific intent. This eliminates unapproved field-aware merging outright.
- **Options at full strength**: field-aware three-way merge gets its best case (including the mandatory-approval variant), so the reasoning behind the losing option survives; whole-visit revisions' queue-size cost is stated plainly rather than minimized.
- **Selection**: why the mandatory-approval merge variant converges to whole-visit's review volume while keeping the rule-maintenance burden, making the choice dominant rather than a taste call.
- **Why the other stays credible**: the re-run trigger — coordinator queue depth and hours measured over the first season — and the constrained re-entry point (proposed-only automatic combination with mandatory approval, or restriction to provably independent administrative fields like observer names).
- **Downstream obligations**: what tablet-sync must accommodate (fetched-revision IDs as base, whole-visit submissions, "pending review, not lost" messaging, competing-revision display) and what review-export must accommodate (head-vs-competitor comparison with common base, select-or-merge resolution UI, resolved-only export gating) — plus what the choice forecloses (automatic merging and field-level deltas in the first release).

Still pending from the Phase 2 stop: your triage of the eight probe gaps (validation-failed submissions, merge-revision base, resolution/submission race, outgoing head after Select, visit_id collision, correcting a resolved visit, idempotency semantics, base-for-edits during unresolved state). Rule on those — fix in the LLD now or defer — and I'll fold in the fixes and move to Phase 3, the EARS specs.