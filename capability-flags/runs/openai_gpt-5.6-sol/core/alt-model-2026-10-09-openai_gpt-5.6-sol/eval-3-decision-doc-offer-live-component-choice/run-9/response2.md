**Phase 2 Draft**
The record-store design now specifies:

- Immutable, complete visit revisions with base revision IDs.
- Automatic advancement only from the uncontested current revision.
- Competing revisions retained as unresolved review work.
- Continued submission acceptance while a visit is unresolved.
- Coordinator resolution over the complete conflict set.
- A new immutable coordinator-authored revision for every resolution.
- Conflict-set version checks to prevent omitted late submissions.
- Export ineligibility whenever unresolved revisions exist.
- Explicit downstream obligations for tablet-sync and review-export.

The full concurrency rationale is recorded in `docs/intent/record-store/decisions/concurrent-visit-edits.md`, including why field-aware merging remains credible if review volume later becomes unsustainable. The completed component draft is in `docs/intent/record-store/record-store-design.md`, and the HLD no longer describes the choice as open.

**Edge-Case Probe**
Before EARS requirements are updated, please triage these gaps:

1. **Atomic submission:** Specify that revision creation, current/conflict classification, conflict-set versioning, and idempotency recording occur atomically. This covers simultaneous edits, duplicate initial creates, and submission-resolution races.
2. **Conflict-set identity:** Specify that versions never repeat and identify one coherent snapshot containing the current revision and exact unresolved membership.
3. **Resolution race outcomes:** Define outcomes when another coordinator resolves first, no conflict remains, or a submission crosses the resolution boundary.
4. **Resolution retries:** Add an idempotency key so a lost response can be retried without creating another resolution revision.
5. **Visit identity invariants:** Decide whether plot UUID and observation date may change between revisions, or only the logical visit ID is immutable.
6. **Idempotency semantics:** Clarify global versus author-scoped keys, semantic versus byte-level payload equality, and behavior when a different worker retries from a shared tablet.
7. **Replayed acceptance results:** Distinguish immutable acceptance-time facts from the visit’s possibly changed current status.
8. **Error taxonomy:** Define machine-readable, no-state-change outcomes for invalid bases, duplicate creation, unknown plots, authorization failures, idempotency mismatches, and stale conflict versions.
9. **Unresolved queue discovery:** Add a list operation with stable ordering so review-export can discover new and enlarged conflicts without missing visits.
10. **History ordering:** Define a per-visit sequence or equivalent stable ordering instead of relying on receipt timestamps.
11. **Export race protection:** Decide whether record-store provides a snapshot or conditional eligibility check, or explicitly delegates that race to review-export.

Please reply with the numbers that should be resolved in this LLD and any that should be deferred. You can also approve all eleven for incorporation before the EARS phase.