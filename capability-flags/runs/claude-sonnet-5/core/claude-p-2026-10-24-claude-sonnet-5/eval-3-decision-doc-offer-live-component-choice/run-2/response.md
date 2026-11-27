The record-store LLD now resolves the concurrency choice. Before you review it, two things need your input.

**1. Decision doc?** This choice has live, multi-criteria tradeoffs (review workload vs. implementation burden vs. risk of silently crossing scientific relationships) and two downstream nodes (tablet-sync, review-export) are about to be sized around it — that clears the bar for a full decision doc rather than just the Decisions & Alternatives row I added. Want one written at `docs/intent/record-store/decisions/concurrency-reconciliation.md` (linked from the row), or is the row enough?

**2. Edge-case gaps.** A context-free probe of the finished design surfaced these internal gaps — please triage which to resolve in the LLD now vs. defer as open questions:

1. Base revision ID that doesn't match any stored revision for the visit (not "absent," not "current," just garbage/unknown).
2. Whether a submission can advance the current revision when its base matches, even if the visit already has unresolved work outstanding.
3. Whether a retried submission (same idempotency key) still returns an accurate "became current" result after the visit's current revision has since changed.
4. What the rejection response looks like for an idempotency-key reuse with a different payload.
5. What's returned on an auth/validation failure, and whether a retry with the same idempotency key is then possible.
6. Whether two concurrent submissions both naming the then-current revision as base could both become "current," violating the single-current-revision invariant.
7. Whether a new submission arriving mid-resolution gets folded into that resolution, missed, or causes the resolution to fail.
8. Whether a resolution naming a stale unresolved set (coordinator's view was fetched before another revision arrived) is rejected, partially applied, or silently wrong.
9. Whether a post-resolution submission based on the old (just-superseded) current revision is treated as ordinary superseded-base, or gets special handling.
10. What happens if a visit's first-ever submission arrives with a non-absent base revision ID.
11. Whether resolving a visit with no unresolved work is a no-op, an error, or undefined.

Once we settle these, record-store's design is done for this session, and tablet-sync/review-export pick up next.