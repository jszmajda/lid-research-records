**Phase 1 — HLD check:** No architecture change. I updated the record-store row to “whole-visit revisions selected” and replaced the stale “unresolved choice” wording with a dependency on record-store’s contract. Tablet-sync and review-export remain unwritten.

**Phase 2 — Record-store LLD:** Drafted at `docs/intent/record-store/record-store-design.md`.

The contract now specifies:

- Every accepted submission is an immutable, complete visit revision with a server-assigned revision ID, base revision ID, author, and acceptance sequence.
- A revision based on the current revision becomes current; any other revision becomes pending and makes the visit unresolved.
- The current revision of an unresolved visit is provisional and never export-eligible.
- Resolution selects one whole revision, declines all other pending revisions, and records the coordinator, selected revision, contributing revision IDs, and time. No fields are merged.
- Resolution requires the exact reviewed-revision set, plus a coordinator idempotency key, so a stale review or lost-response retry cannot silently decline unseen edits.
- Retrieval exposes current state, revision and resolution history, and unresolved review items.
- Submission idempotency is per author and covers visit ID, base revision ID, and canonical payload.

An edge-case probe surfaced gaps around status mutability, idempotent replay after a revision changes status, concurrent first submissions, resolution retries, off-line bases on superseded revisions, and review authorization. Those are now addressed in the LLD.

Two assumptions I need you to confirm before I lock this design:

1. **Plot identity:** a visit’s plot reference is fixed at its first revision; later revisions cannot change it.
2. **Review authorization:** the existing identity provider supplies a coordinator role, and only that role can read history, list unresolved work, or resolve. Submitting and current-state retrieval need only an authenticated worker.

Also: this choice will remain live for tablet-sync and review-export sizing, so it may earn a decision doc. Do you want `docs/intent/record-store/decisions/whole-visit-revisions.md`, or is the LLD Decisions row enough?

If this LLD is approved, the next phase is EARS: adding and revising `record-store-specs.md` for the revision, unresolved-work, and resolution behavior.