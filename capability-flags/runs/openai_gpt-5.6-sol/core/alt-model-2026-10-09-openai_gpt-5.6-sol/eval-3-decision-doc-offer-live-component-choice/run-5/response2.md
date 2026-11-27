**Record-Store Design**
Completed:

- `docs/intent/record-store/record-store-design.md`
- `docs/intent/record-store/decisions/concurrent-visit-edits.md`

The design now specifies:

- Immutable, complete visit revisions with base revision IDs.
- Atomic current-revision advancement and conflict creation.
- Whole-revision coordinator resolution with stale-review protection.
- Export exclusion while any revision conflict remains unresolved.
- Tablet obligations for base IDs, idempotency, pending submissions, and competing outcomes.
- Review/export obligations for whole-visit comparison, complete resolution payloads, provenance, and export gating.
- Why field-aware merging remains credible if review volume becomes unsustainable, and the governance, testing, client tracking, and provenance it would require before adoption.

The independent edge-case probe found these unresolved contract questions:

1. Should a missing-base submission for an existing visit be rejected, rather than accepted as competing?
2. Should resolution be allowed only when the unresolved set is nonempty?
3. Must coordinator payloads pass the same validation as worker submissions, including fixed visit identity?
4. What is the idempotency-key scope: actor plus operation, visit plus operation, or global?
5. Does a failed stale-review attempt consume its idempotency key?
6. Should a coordinator revision use the previous current revision as its base while separately linking every reviewed revision as provenance?
7. Which visit attributes, such as plot and observation date, remain editable across revisions rather than defining visit identity?
8. On a delayed retry, should the original acceptance response retain its historical resolution state or include newly computed current state?
9. Should retrieval of a nonexistent visit return `not found` rather than adding an empty resolution state?
10. Should reviewed revision IDs use order-independent set semantics while rejecting duplicates and foreign IDs as malformed?
11. What exact canonicalization determines whether retried payloads are identical?
12. Which payload constraints belong here, including cover ranges, duplicate species, observer rules, text size, and total payload size?
13. Must retrieval return a transactionally consistent snapshot of the current pointer and unresolved set?
14. What deterministic tie-breaker orders history entries with equal receipt times?

Please review the design and indicate which numbered gaps should be resolved in this LLD versus deferred. I’ll update the design from that ruling before drafting the EARS requirements.