## Phase 4 — Intent-Narrowing Edge Audit

I've identified several forks in the specs that need resolution before tests:

**Within record-store specs:**

1. **REC-007/008 — Gap in revision numbers**: What if a submission's `base_revision` is less than `head_revision - 1` (a gap)? The spec says "matches" or "does not match" — does a gap count as "does not match" with same rejection behavior, or is it a distinct error?

2. **REC-009 — Three or more competitors**: "Multiple accepted revisions share the same base_revision" — the resolution operation (REC-010/011) takes a single `selected_revision`. Does the coordinator resolve all competitors at once, or pairwise? If pairwise, the head changes after each resolution.

3. **REC-010/011 — Invalid selected_revision**: What if `selected_revision` is not one of the competing revisions? Reject? Treat as merged with empty merge?

4. **REC-012 — Resolution revision's base_revision**: The new resolution revision becomes head. Does it have a `base_revision` field? If a worker later submits with the old head's revision as base, does it conflict with the resolution revision?

**Cross-segment (tablet-sync, review-export not yet designed):**

5. **Submission envelope size**: The whole visit fields are sent on every edit. At ~2KB per visit, this is fine for 6K visits/season, but should the LLD note an upper bound?

6. **Idempotency key scope**: Is the idempotency key unique per (worker, visit) or globally? The LLD says "client-generated, unique per submission attempt" — globally unique (e.g., UUID) is simplest.

Please resolve these, starting with the within-spec forks (1-4).