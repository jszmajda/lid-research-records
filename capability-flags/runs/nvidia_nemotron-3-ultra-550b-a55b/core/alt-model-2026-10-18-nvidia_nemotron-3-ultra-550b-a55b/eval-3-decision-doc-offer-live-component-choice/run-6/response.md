**Phase 3 Consistency Verification:**

| Check | Result |
|-------|--------|
| Coverage | All LLD behaviors (submission envelope, revision model, current-state response, resolution) now have corresponding EARS specs (REC-007 through REC-012) |
| Contradiction | No specs conflict |
| Implicit scoping | Specs use explicit conditions ("When a submission's baseRevisionId matches...") — no reliance on section context |
| Context-free | Each spec stands alone with concrete conditions |

**Phase 4 — Intent-Narrowing Edge Audit**

**Cross-segment interaction (site-catalog):**
- REC-001/REC-007-009 validate plot references. The design says "validate field types and plot references before accepting." Does validation mean: (a) reject if plot ID doesn't exist in catalog, or (b) accept but flag? The HLD says site-catalog "distributes the field catalog" — tablets have the catalog offline. I'd lean (a) reject invalid plot IDs at submission, but this is a fork.

**Composition forks within record-store:**

1. **REC-007 + REC-008 — simultaneous submissions with same baseRevisionId:** Two workers submit from revision 3 concurrently. Specs don't specify ordering. One becomes revision 4 (head), the other becomes competing. But which? Current specs allow either outcome.

2. **REC-008 — "ancestor of current head" with existing competing revisions:** Visit has head=rev4, competing=[rev4a, rev4b]. A submission arrives with baseRevisionId=rev3 (ancestor). Does it become a third competing revision (rev4c)? Or is it rejected because the head has moved past? Design says "two or more competingRevisions" but REC-008 only covers one level of ancestor.

3. **REC-010 + new submission during competing status:** Visit status=competing. A worker submits with baseRevisionId=rev4a (one of the competing revs). Specs don't address this. Accept as another competing revision? Reject? Fast-forward that branch?

4. **REC-012 — resolution editing:** "selecting one as the basis and optionally editing fields." If the coordinator edits fields, does the resolved revision carry a new baseRevisionId? The design says it "becomes the visit's new head" — but what baseRevisionId does it claim? This affects subsequent submissions.

**Per-spec divergence probes (new specs):**

| Spec | Divergent readings |
|------|-------------------|
| REC-007 | "Matches current head" — at submission receipt time? At transaction commit time? Race window matters. |
| REC-008 | "Ancestor but not head" — immediate parent only? Any ancestor? What if competing revisions already exist? |
| REC-009 | "Not in revision history" — rejected with 400? 409? What error payload? |
| REC-010 | "Status competing excludes from export" — does this apply to /visits list endpoint, or only to the CSV export operation? |
| REC-011 | "Status clean includes in export" — same question: which endpoints? |
| REC-012 | "Coordinator selects one as basis and optionally edits" — does the edit create a new submission payload, or is it a direct mutation? Does it inherit the selected revision's baseRevisionId? |

**Please resolve these forks. I'll update the design/specs per your answers, then proceed to tests.**

---

Which forks should I prioritize? I can:
1. Address all now (more conversation rounds)
2. Resolve the critical-path ones first (simultaneous submissions, competing-status submissions, resolution baseRevisionId) and defer the rest as Open Questions
3. You pick a subset to resolve now

How do you want to proceed?