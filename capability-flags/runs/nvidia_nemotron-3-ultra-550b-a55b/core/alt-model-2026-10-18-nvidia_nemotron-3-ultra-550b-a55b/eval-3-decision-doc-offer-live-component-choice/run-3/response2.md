**Phase 3 — EARS specs updated** with whole-visit revisions specs (REC-007 through REC-012).

Now **Phase 4 — Intent-narrowing edge audit**. I found these cross-spec and cross-segment issues:

---

### Cross-spec forks (within record-store)

| Spec(s) | Fork |
|---------|------|
| **REC-007 vs first submission** | REC-007: "omits baseRevision → reject". But LLD says baseRevision is "absent for first submission". Does first submission create the visit without baseRevision, or is a visit created beforehand? |
| **REC-008 + REC-009 race** | Two submissions arrive concurrently with `baseRevision=5` (current head). First processed → REC-008 makes it new head (rev 6). Second processed → REC-009 sees baseRevision behind head → competing revision. Order-dependent outcome. Intent: should both become competing revisions? |
| **REC-009 "behind head"** | What if `baseRevision > head` (client has stale head but newer base)? Reject? |
| **REC-011 resolution** | "Selecting one revision as basis" vs "manual combination". LLD allows manual combination. Does REC-011 cover both? |
| **Idempotency + rebase** | Worker submits (baseRev=2) → conflict. Rebases locally to baseRev=3, retries with same idempotency key but different payload (includes rebase). REC-003 rejects different payload. But this is intentional rebase, not a bug. |

### Cross-segment obligations (tablet-sync, review-export)

| Segment | Implied requirement not yet in its design |
|---------|-------------------------------------------|
| **tablet-sync** | Local draft stores `baseRevision`. On conflict response, displays competing revisions from server. Manual rebase: worker edits draft against latest head, resubmits with new `baseRevision`. |
| **tablet-sync** | Idempotency key reuse after rebase: must allow same key with updated payload + new baseRevision. |
| **review-export** | Revision comparison screen: side-by-side or unified diff of whole visits (all fields). |
| **review-export** | Export eligibility: visits in "unresolved" state (has competing revisions) excluded from Friday CSV. |
| **review-export** | Resolution record: coordinator ID + contributing submission IDs attached to new head revision. |

---

### Questions for resolution

1. **First submission**: Should `baseRevision` be optional (0 or omitted) for the first submission of a visit UUID, creating visit + revision 1? Or must visits be created separately?
2. **Concurrent same-base submissions**: Should both become competing revisions (losing the "clean head" path), or is the race acceptable?
3. **baseRevision > head**: Reject with error, or treat as "behind"?
4. **Manual combination in REC-011**: Add "or a manual combination of competing revisions" to the spec?
5. **Idempotency key on rebase**: Allow same key with different payload when baseRevision advances? (Current REC-002/003 forbid this.)

**STOP for user review.** Resolve these forks, then I'll finalize specs and proceed to tests-first.