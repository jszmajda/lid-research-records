Updated the HLD and completed the whole-visit revision design in:

- `docs/high-level-design.md`
- `docs/intent/record-store/record-store-design.md`

The design now defines:

- Immutable, complete visit revisions with base revision IDs and globally unique submission keys.
- Automatic advancement only when an edit is based on the current revision and no review is pending.
- Competing edits accumulating in a review set without overwriting or merging submissions.
- Coordinator resolution by selecting one complete revision, with exact review-set verification to prevent overlooking newer submissions.
- Current-state, full-history, submission, and resolution contracts.
- Auditable resolution records and export ineligibility while a visit remains unresolved.

The LLD edge-case probe found these gaps for you to triage:

1. **Cross-visit key race:** How should simultaneous submissions using the same global key on different visits be serialized?
2. **Cross-worker retry:** Should another worker using an existing key receive the original result, an idempotency conflict, or an authorization error?
3. **Resolution retry:** Should an identical resolution retry return the original resolution rather than “not unresolved”? Concurrent coordinator attempts need the same clarification.
4. **Consistent retrieval:** Should current revision, unresolved status, and review set be returned from one atomic snapshot?
5. **Retry equivalence:** Should JSON key order, formatting, and equivalent numeric forms count as identical, requiring defined canonicalization?
6. **Failed submissions and error precedence:** Do invalid submissions reserve keys, and which error wins when validation and idempotency both fail?
7. **Expected review-set validation:** Should IDs be order-independent and duplicate-free, and which error takes precedence for an invalid selection plus stale set?
8. **History ordering:** Should revisions and resolutions share a deterministic sequence to handle equal timestamps?
9. **Review-set ordering:** Should returned review revisions and recorded IDs use stable receipt order?
10. **Machine-readable errors:** Which stable error codes and precedence rules should clients receive?

Physical storage, backups, retention, pagination, filtering, HTTP status mapping, and tablet/review UI details remain deferred.

Please review the LLD and indicate which of these gaps to settle now and which to defer. Once you approve the LLD, I’ll update the EARS specs.