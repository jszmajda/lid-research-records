I've stopped at the design review boundary. Here is what's on the table for your approval before anything else moves.

**HLD** — `record-store` is now marked `Drafted; whole-visit revisions`, and the dependency paragraph states the selected mechanism instead of an open choice.

**Record Store LLD** — the open-choice section is replaced by a concrete whole-visit revision model:
- Each submission is a complete visit carrying `visit_id`, `plot_id`, `base_revision_id`, `idempotency_key`, observation date, observers, species cover, and notes. The server records receipt time; it is not authority.
- Revisions form a tree per visit. A null base is valid only for the first revision. While a visit is resolved, a submission whose base equals the current revision extends it; every other base (null on an existing visit, an ancestor, a competing branch, or any base on an unresolved visit) is retained as a competing revision and marks the visit unresolved. No current revision exists while unresolved.
- Resolution designates one complete revision — a competing revision or a coordinator-authored complete revision built from one — and records coordinator identity, chosen revision, contributing revision IDs, and time. No field-level combination ever occurs. A stale resolution (its contributing set no longer matches) is rejected.
- Retrieval returns current values only when resolved; when unresolved it returns competing revision summaries and no values. History returns every revision with base linkage.
- Decisions & Alternatives records the policy, conflict detection, resolution shape, unresolved retrieval, concurrent resolution, and idempotency.

**EARS** — `REC-001`–`REC-006` are retained unchanged; `REC-007`–`REC-017` now pin the whole-visit behavior (complete-field storage, current-revision acceptance rules, unresolved invariant, resolution shape, retrieval shapes, base validation, stale-resolution rejection, and history retention). All remain `[ ]` since no implementation exists.

**Edge-audit items I did not settle for you:**
1. **Unresolved retrieval (REC-013)** returns no field values. If a worker reopens an unresolved visit on a tablet, that surface would come from history instead. Confirm that's the intended split.
2. **Identical competing revisions** — two workers submitting byte-identical revisions from the same base still enter review. Auto-resolve or keep the review item?
3. **Resolutions restricted to tips** — currently a coordinator may designate any complete revision, including a non-tip. Restrict to tips?
4. **Site-catalog stale note** — `site-catalog-design.md:24` still says tablet-sync "remains pending that choice." It's a sibling segment; want me to correct that line?

**Decision-doc offer** — whole-visit revisions vs. field-aware merge is a live trade-off that tablet-sync and review-export will be sized around. Should I record it as a full decision doc in `docs/intent/record-store/decisions/`, or leave it as the Decisions row it is now?

No tablet-sync or review-export files were touched, and no code or tests were written. Approve the LLD and specs as written (or give numbered feedback), and tell me which of items 1–4 and the decision-doc offer to act on.