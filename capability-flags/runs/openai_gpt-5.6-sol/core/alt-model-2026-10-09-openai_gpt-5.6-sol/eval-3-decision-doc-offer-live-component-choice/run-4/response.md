The whole-visit revision design is drafted in `docs/intent/record-store/record-store-design.md`, and the stale HLD dependency text is updated. The design now defines immutable complete revisions, base revision IDs, stable current state during conflicts, unresolved review sets, coordinator resolution, provenance, idempotent submission, and export ineligibility while review remains unresolved.

The Phase 2 edge-case probe found several points to settle before EARS specs:

1. Make submission, current-pointer movement, unresolved-set changes, and retrieval snapshots atomic per visit.
2. Let coordinators retain the existing current revision, select a competing revision, or author a complete replacement. For replacements, use the prior current revision as the base while the resolution record names every considered revision.
3. Decide whether a second base-less submission using an existing visit UUID is rejected as an identity collision or retained as competing review work.
4. Confirm that plot and observation date may be corrected between revisions, and that submissions referencing a valid archived plot remain acceptable.
5. Add idempotency to resolution operations and define machine-distinguishable outcomes for conflicts, stale versions, validation failures, and retryable failures.
6. The whole-visit versus field-aware choice plausibly warrants a full decision document because future maintainers may reconsider the accepted review workload. Should I add one, or keep the current Decisions & Alternatives row?

Please reply with approval of the recommended clarifications plus your choices for items 3 and 6, or provide numbered changes. I’ll then finalize Phase 2 before drafting the record-store EARS specs.