The LLD now includes the full rationale for choosing whole-visit revisions and documents the downstream implications for tablet-sync and review-export.

---

## Phase 4 Edge Audit — Remaining Forks Needing Your Decision

| Spec | Fork A | Fork B | My Recommendation |
|------|--------|--------|-------------------|
| **REC-008** | Any `base_revision` ≠ latest resolved → competing revision (even future/non-existent) | Only `base_revision` < latest resolved → competing; `base_revision` > latest resolved → reject as invalid | **Fork B** — reject future revisions as invalid; they indicate client bug or clock skew |
| **REC-010** | "Initial visit" = revision 0 (implicit empty visit created at visit registration) | "Initial visit" = first submission (revision 1); `current_revision=0` means no payload | **Fork B** — first submission is revision 1; `current_revision=0` means no payload yet (visit created on first submit) |
| **REC-012** | Resolution must include ≥1 contributing revision (coordinator picks a base) | Resolution can have empty `contributing_revisions` (coordinator writes from scratch) | **Fork A** — require at least one contributing revision; coordinator always starts from a submitted visit |
| **REC-009** | Competing revisions only form when sharing a *resolved* base revision | Competing revisions can chain (new submission cites a competing revision as base) | **Fork A** — single-generation only; `base_revision` must be a resolved revision |

**Please confirm or adjust these four decisions.** Once resolved, I'll update the specs and proceed to Phase 5 (tests-first).