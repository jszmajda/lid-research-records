**Edge Audit Findings — please resolve before I proceed to tests:**

### Cross-spec / Cross-segment Interactions

1. **REC-007 vs REC-011 race condition**: "at submission time" (007) vs "does not match latest resolved" (011) — if two submissions arrive concurrently for the same base, both could pass the check before either is recorded. The LLD says "the server must not treat arrival order as evidence of authority" — but one must win. Need a tie-break rule (e.g., first-write-wins, or reject both and require rebase).

2. **REC-010 "competing revisions already exist for that base"**: Ambiguous whether "for that base" means same `base_revision_id` OR same `visit_id` with any open cycle. The LLD defines a cycle by shared `base_revision_id` — so only same-base competing revisions group. But what if Worker A submits from base R1, then Worker B submits from base R1 before A's is processed? Both should be in the same cycle.

3. **REC-012 resolution base revision**: "base revision ID pointing to the latest resolved revision" — but if the cycle being resolved was based on R1, and a later resolved revision R2 exists (from a different cycle), the new resolution's base should be R2. This means the resolved payload must be compatible with R2's state. Does the coordinator see R2 when resolving the R1 cycle?

4. **REC-018 cycle completeness**: "cycles containing competing revisions that have not been resolved" — a cycle is resolved when ALL its competing revisions are superseded. What if a cycle has 3 competing revisions and only 2 are resolved? The third remains `competing` — the cycle stays open. Is partial resolution allowed? The LLD implies coordinators resolve the whole cycle at once.

5. **Cross-segment: Tablet-sync contract**: The LLD says tablet-sync "retains base revision IDs and displays pending competing revisions." But the submission envelope (REC-007/008/009/010/011) doesn't specify what the server returns on acceptance — the new revision ID? The current cycle state? Tablet-sync needs to know what to display to the worker after submission.

6. **Cross-segment: Review-export contract**: The LLD says review-export "excludes unresolved visits from its export set" and "needs a revision comparison workflow." REC-015/016/018/019 define the query surface. But: does "unresolved visit" mean any visit with an open cycle, or only visits with NO resolved revision? REC-019 says "no resolved revision AND open cycle = no current state" — but REC-016 says "has resolved revision AND open cycle = flag unresolved work." Which visits are export-eligible?

### Per-Spec Divergent Readings (genuine forks)

**REC-007**: "at submission time"
- Reading A: Check at request receipt (optimistic, race window)
- Reading B: Check at transaction commit (pessimistic, serializes)
- Reading C: Check against a snapshot taken at request start (MVCC-style)

**REC-010**: "competing revisions already exist for that base"
- Reading A: Any revision with status `competing` and same `base_revision_id`
- Reading B: Any revision with status `competing` for the same `visit_id` (ignoring base)
- Reading C: Only revisions accepted in the same "cycle" — but "cycle" isn't defined until resolution

**REC-012**: "base revision ID pointing to the latest resolved revision"
- Reading A: The resolution's base is always the absolute latest resolved revision (may be newer than the cycle's base)
- Reading B: The resolution's base is the cycle's base revision (R1), creating a parallel history
- Reading C: The coordinator must rebase the resolved payload onto the latest resolved revision before submitting

**REC-015/016**: Current visit with open cycle
- Reading A: Return latest resolved + flag (coordinator sees both)
- Reading B: Return 404 when open cycle exists (no current state until resolved)
- Reading C: Return latest resolved ONLY if cycle base matches that revision; otherwise 404

**REC-018**: Open review cycles query
- Reading A: Return all cycles with ≥1 `competing` revision
- Reading B: Return only cycles where ALL revisions are `competing` (none resolved yet)
- Reading C: Return cycles grouped by visit, not by base revision

### Implicit Scope Issues

- **REC-020**: "observer list is non-empty" — is this a universal rule, or only for certain visit types? The HLD says "observer names" are part of every visit. But what if a visit is created programmatically?
- **REC-008**: "first submission for a visit" — assumes visit_id is client-generated and unique. What if two workers independently create visits for the same plot on the same day with different UUIDs? (Catalog has plot UUID; visit UUID is separate. This is a tablet-sync concern, but the record-store accepts any visit_id.)

---

**Please resolve the forks above** (numbered items). For each, state the intended reading or provide a narrowing edit. I'll then update the specs and LLD accordingly before proceeding to Phase 5 (tests).