Drafted the whole-visit record-store design in `docs/intent/record-store/record-store-design.md` and updated `docs/high-level-design.md`. The design now covers revision lineage, submission and idempotency, branch-head updates, retrieval, coordinator resolution, atomicity, and downstream obligations. Tablet-sync and review/export remain untouched.

The edge-case probe found these record-store gaps to triage:

1. **Global idempotency:** Per-visit serialization does not prevent concurrent reuse of one key across different visits.
2. **Resolution retries:** An identical resolution retried after a lost response currently looks invalid rather than returning the original success.
3. **Retrieval consistency:** Current-state and history responses need an explicit committed-snapshot guarantee.
4. **Error contract:** Stable error fields and precedence need definition when multiple validation failures apply.
5. **Authorization:** Permissions for editing others’ visits, retrieving records, and resolving competition are unstated.
6. **Ordering:** Competing-head and history ordering is unspecified.
7. **Canonical retry equivalence:** Optional values and collection ordering need defined comparison semantics.
8. **Resolution provenance:** “All competing submission IDs” could mean head-producing submissions only or every submission on competing branches.

Which gaps should I resolve in the LLD, and which should remain deferred? Once you’ve triaged them, I’ll revise the design for Phase 2 approval before updating the EARS specifications.