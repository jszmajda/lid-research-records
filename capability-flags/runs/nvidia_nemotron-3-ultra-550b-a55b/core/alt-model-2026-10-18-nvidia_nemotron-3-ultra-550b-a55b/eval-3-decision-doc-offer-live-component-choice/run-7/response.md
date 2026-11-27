Now let me present the Phase 2 (LLD) and Phase 3 (EARS) outputs, then run the Phase 4 intent-narrowing edge audit.

---

## Phase 2 Complete: Updated LLD

The record-store design now reflects **whole-visit revisions** as the selected concurrency policy. Key additions:
- **Decisions & Alternatives table** recording the choice with rationale
- **Submission Envelope** with `base_revision`, complete payload, idempotency key
- **Current-State Response** distinguishing resolved state from unresolved competing revisions
- **Unresolved-Work Representation** as competing revisions sharing a base revision
- **Resolution Operation** creating new resolved revisions with contributor tracking
- **Open Questions** deferred for implementation (max competing revisions, resolution-from-scratch, retention)

## Phase 3 Complete: Updated EARS Specs

Added 9 new specs (REC-007 through REC-015) covering:
- Submission acceptance as new/competing revision based on `base_revision` match (REC-007, REC-008)
- Competing revision preservation (REC-009)
- Current-state response with `has_unresolved` flag and competing revisions array (REC-010, REC-011)
- Resolution creating new resolved revision with contributor metadata (REC-012, REC-013)
- Validation rejections for unknown visits and invalid payloads (REC-014, REC-015)

---

## Phase 4: Intent-Narrowing Edge Audit

### Cross-Spec & Cross-Segment Interactions

| # | Issue | Specs Involved | Question |
|---|-------|----------------|----------|
| 1 | **Stale base_revision handling** | REC-008, tablet-sync | When a tablet's `base_revision` is older than the server's latest resolved revision (normal case after disconnection), the submission becomes a competing revision per REC-008. Tablet-sync must surface this to the worker ("your edit is now in review"). Is this the intended UX? |
| 2 | **Non-existent base_revision** | REC-008 | If a submission cites `base_revision=10` but latest resolved is `5` (e.g., bug, clock skew, or malicious client), REC-008 accepts it as competing. Should this be rejected instead? |
| 3 | **Second-generation competing revisions** | REC-009, REC-010 | Competing revisions share a *resolved* base revision. What if a new submission cites `base_revision=6` where 6 is a competing revision (not resolved)? Current specs don't address this chain. |
| 4 | **"Initial visit" definition** | REC-010, REC-011 | Design says `current_revision=0` when no resolution yet, with `current_payload` = "initial visit". Is revision 0 a pre-existing record, or is the first submission revision 1? This affects tablet-sync's initial `base_revision`. |
| 5 | **Resolution from scratch** | REC-012, Open Q#2 | Can a coordinator create a resolved revision not based on any competing revision? Spec says "selecting one revision as the basis and optionally incorporating edits from others" — implies at least one contributing revision. |
| 6 | **Review-export eligibility** | REC-010, review-export | Visits with `has_unresolved=true` are excluded from Friday CSV. What if all competing revisions are from the same worker (self-correction)? Still excluded until explicit resolution? |
| 7 | **Competing revision limit** | Open Q#1 | No max on competing revisions per visit. Could a busy plot accumulate many? Tablet-sync needs to know if there's a cap. |

### Per-Spec Divergent Readings (Genuine Forks)

| Spec | Fork A | Fork B | Resolution Needed |
|------|--------|--------|-------------------|
| **REC-008** | Any `base_revision` ≠ latest resolved → competing revision (even future/non-existent) | Only `base_revision` < latest resolved → competing; `base_revision` > latest resolved → reject as invalid | Choose: accept-all-mismatch vs. reject-future |
| **REC-010** | "Initial visit" = revision 0 (implicit empty visit created at visit registration) | "Initial visit" = first submission (revision 1); `current_revision=0` means no payload | Choose: revision 0 exists vs. first submission is revision 1 |
| **REC-012** | Resolution must include ≥1 contributing revision (coordinator picks a base) | Resolution can have empty `contributing_revisions` (coordinator writes from scratch) | Choose: require base vs. allow from-scratch |
| **REC-009** | Competing revisions only form when sharing a *resolved* base revision | Competing revisions can chain (new submission cites a competing revision as base) | Choose: single-generation only vs. allow chains |

---

**Please review the LLD and specs above, and resolve the forks in the table.** I'll incorporate your decisions before proceeding to Phase 5 (tests-first).