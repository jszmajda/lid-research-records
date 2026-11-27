**Phase 2 Draft**
Completed:

- `docs/intent/record-store/record-store-design.md`
- `docs/intent/record-store/decisions/concurrent-visit-edits.md`
- `docs/high-level-design.md`

The design now defines immutable complete revisions, base-revision submission, unresolved review cases, coordinator-authored resolutions, optimistic review versioning, export holds, and the downstream tablet/review contracts. `git diff --check` passes.

**Edge-Case Probe**
Before drafting EARS requirements, please decide which gaps to resolve now versus defer:

1. **Corrected-resolution lineage:** Should a coordinator-authored corrected revision descend from the previous current revision, identify one candidate as its base, or have multi-candidate lineage only through the resolution record?
2. **Concurrent creation:** If two tablets submit `base = null` for the same new visit UUID, should the second submission become a review candidate or be rejected? A different plot UUID would indicate an identity collision.
3. **Older branch during review:** If a submission is based on a revision outside the open case, should that base join the candidate set, remain lineage-only, or be rejected?
4. **Resolution validation:** The design needs behavior for selecting a revision outside the case, omitting candidates, submitting an invalid corrected payload, resolving a closed case, and retrying or conflicting on a resolution idempotency key.
5. **Historical retry response:** An idempotent submission retry may return an original `needs_review` result after that case has changed or closed. Should the response return only the historical acceptance result, or include current visit state as well?
6. **Error contract:** Authentication, invalid plot/base, UUID collision, idempotency conflict, stale case version, and unauthorized resolution need stable error codes and retriable/non-retriable classification.
7. **Duplicate content:** A new idempotency key may submit a payload identical to the current revision or an existing candidate. Should that create a distinct immutable revision or be treated as a no-op?
8. **Lifecycle invariants:** The design can explicitly pin one open case per visit, atomic review snapshots, stable plot UUIDs across revisions, new case identity after resolution, and whether accepted submissions can ever be withdrawn.

I recommend resolving items 1–6 and 8 now; item 7 could reasonably be deferred if preserving every distinct submission is the default.

There is also one cross-segment cascade: `site-catalog-design.md` still says tablet reconciliation is pending the concurrency choice. May I update that sentence when incorporating your answers?