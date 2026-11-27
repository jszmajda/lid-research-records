## Phase 3: EARS Specs — Ready for Review

I've updated the record-store design and specs for **whole-visit revisions**. Key additions:

| Spec | Behavior |
|------|----------|
| REC-007 | Base revision must be current or direct ancestor |
| REC-008 | Base matches current → new candidate revision |
| REC-009 | Base is ancestor → competing revision at same level |
| REC-010 | Multiple candidates at same level → competing state, excluded from clean response |
| REC-011 | Coordinator selects winner → resolved |
| REC-012 | Coordinator creates combined revision → resolved |
| REC-013 | Clean state returns current content or competing indication |
| REC-014 | History returns all submissions with metadata |
| REC-015 | Competing revisions returns full payload + author + base revision |

---

## Phase 4: Intent-Narrowing Edge Audit — Divergent Readings

Before tests, I see these genuine forks:

1. **REC-007 "direct ancestor"**: In whole-visit revisions, revisions form a linear chain until competition creates branches. Does "direct ancestor" mean any prior revision in the chain, or only the immediate parent? If Worker A submits rev 3, Worker B submits rev 3 (competing), then Worker C submits based on rev 2 — is rev 2 a "direct ancestor" of the current (competing) rev 3?

2. **REC-009 "ancestor of the current revision"**: When there are competing revisions at level N, which one is "the current revision"? The spec says "the current revision" singular, but competing state has multiple candidates at the same level.

3. **REC-010 "same revision level"**: If two submissions arrive with base=3 (current=3), both get revision 4 → competing. But if a third submission arrives with base=4 (where 4 is already a competing set), what revision number does it get? 5? And does it compete with the existing 4s or create a new level?

4. **REC-012 "combined revision"**: Must the combined content be a valid visit payload (pass validation), or can it be any arbitrary combination? Does validation run on the combined result?

5. **REC-013 vs REC-005**: REC-005 says "indicate whether unresolved review work exists" on visit retrieval; REC-013 says clean state returns "indication of competing state." Are these the same retrieval endpoint with different behaviors, or different endpoints?

6. **REC-004 "regardless of concurrency policy outcome"**: This is correctly policy-agnostic, but with whole-visit revisions, "outcome" could mean either coordinator selection or combination. Should the original submissions retain links to which resolution path was taken?

7. **Cross-spec: REC-008/009 + REC-014**: History returns "resolution status" — what are the possible statuses? pending, competing, resolved-winner, resolved-combined, rejected?

---

**Please resolve these forks**, then I'll proceed to Phase 5 (tests-first).