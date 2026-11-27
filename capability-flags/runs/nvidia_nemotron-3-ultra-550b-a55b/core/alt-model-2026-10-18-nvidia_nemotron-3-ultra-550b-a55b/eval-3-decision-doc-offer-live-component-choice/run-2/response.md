## Phase 4 — Intent-Narrowing Edge Audit

I've analyzed the updated LLD and specs for cross-spec and cross-segment ambiguities. Here are the genuine forks needing resolution:

---

### Cross-Segment (with `site-catalog`)

**1. Archived plot submission**  
REC-013 validates plot reference exists in catalog. The catalog design (CAT-004) says archived plots retain UUIDs for historical records.  
**Fork:** Can a worker submit a visit for an *archived* plot?  
- A: Yes — archived plots remain valid for historical data entry  
- B: No — archived plots are excluded from new visits entirely  

**2. Catalog version staleness**  
Tablet-sync caches catalog snapshots (CAT-003). A worker may submit with a plot UUID from a stale snapshot where the plot was since archived or its display code changed.  
**Fork:** Does record-store validate against the *current* catalog or accept any historically valid UUID?  
- A: Validate against current catalog (requires catalog access at submission time)  
- B: Accept any UUID that was ever valid (simpler, allows stale-catalog submissions)  

---

### Within-Segment Spec Interactions

**3. First submission for a new visit (REC-007, REC-008)**  
**Fork:** What is the "latest revision" of a visit that doesn't exist yet?  
- A: `latestRevision = 0` for non-existent visits; first submission must have `baseRevision = 0`  
- B: Non-existent visits have no latest revision; first submission uses a distinct "create" path (no baseRevision check)  
- C: `baseRevision` is optional/nullable on first submission; presence implies update, absence implies create  

**4. Competing revision detection (REC-009)**  
Design: "two or more accepted submissions share the same baseRevision".  
**Fork:** If three submissions arrive with baseRevision=5, then a fourth arrives with baseRevision=6 (based on one of the three), is the fourth competing?  
- A: Yes — any submission whose base is part of an unresolved competing set is also competing  
- B: No — only submissions sharing the *original* base revision compete; subsequent edits fork from a chosen branch  
- C: The fourth is rejected because baseRevision=6 doesn't exist yet (latest is 5 with competing set)  

**5. Resolution submission idempotency (REC-002, REC-003, REC-011)**  
**Fork:** Do resolution submissions use the same idempotency key rules as worker submissions?  
- A: Yes — identical key + identical payload = replay; different payload = reject  
- B: No — resolutions are coordinator actions with separate idempotency semantics  

**6. Superseded revision tracking (REC-011)**  
Design: "marks the listed revisions as superseded" but no spec defines this.  
**Fork:** How is "superseded" represented and queried?  
- A: Boolean flag on each revision in history; included in retrieval response  
- B: Separate resolution record linking to superseded revisions; not a flag on the original revision  
- C: Implicit — revisions not in the current resolved lineage are superseded; no explicit marker needed  

**7. Resolution authorization (REC-011)**  
Design says "coordinator resolves" but no spec requires coordinator role.  
**Fork:** Can any authenticated worker submit a resolution, or only coordinators?  
- A: Only users with coordinator role can submit resolutions  
- B: Any authenticated user can resolve; coordinator role is a UI/workflow concept only  

**8. Resolution payload validation (REC-011, REC-013, REC-014)**  
**Fork:** Does a resolution submission go through the same plot/type validation?  
- A: Yes — same validation as any submission  
- B: No — resolution is trusted; validation skipped  

**9. Empty competing set after resolution (REC-011 vs REC-012)**  
REC-011: resolution clears competing set. REC-012: no competing → resolvedPayload = latest.  
**Fork:** What if resolution payload is identical to one competing revision? Does it still create a new revision?  
- A: Yes — resolution is a distinct decision event; new revision always created  
- B: No — if identical to an existing revision, point to that revision instead  

---

### Divergence Probes (Per-Spec Ambiguities)

**REC-007/008 — Base revision matching**  
*Deliberately divergent readings a blind implementer could take:*  
- "Match" means exact integer equality — but what if latestRevision is `null` (no revisions)?  
- Rejection response shape: "return the current latest revision and its payload" — if visit doesn't exist, what is returned? Error? Empty payload?  

**REC-009 — "Share the same base revision"**  
- Does "share" mean *exactly* the same integer, or could it mean "same base state" (e.g., base 5 and base 5 but different idempotency keys)?  
- What if baseRevision=5 submissions arrive, then baseRevision=6 (forked from one of them) arrives before resolution?  

**REC-011 — ResolvedFrom list**  
- Must `resolvedFrom` include *all* competing revisions, or can it be a subset?  
- What if `resolvedFrom` includes a revision that wasn't competing?  
- What if `resolvedFrom` is empty?  

---

### Summary

| # | Fork | Location | Recommended Resolution |
|---|------|----------|------------------------|
| 1 | Archived plot submission | REC-013 × CAT-004 | **A** — archived plots valid for historical entry |
| 2 | Catalog version staleness | REC-013 × CAT-003 | **B** — accept historically valid UUIDs (offline-first) |
| 3 | First submission base revision | REC-007, REC-008 | **A** — latestRevision=0, baseRevision=0 for create |
| 4 | Competing set expansion | REC-009 | **C** — reject submissions based on non-existent revisions |
| 5 | Resolution idempotency | REC-002, 003, 011 | **A** — same rules apply |
| 6 | Superseded representation | REC-011 | **A** — boolean flag on revision in history |
| 7 | Resolution authorization | REC-011 | **A** — only coordinators can resolve |
| 8 | Resolution validation | REC-011, 013, 014 | **A** — same validation |
| 9 | Identical resolution payload | REC-011, 012 | **A** — new revision always created |

---

**STOP for your review.** Please resolve the forks above (confirm recommendations or choose alternatives), then I'll update the LLD and specs accordingly before proceeding.