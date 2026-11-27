I've finished drafting the record-store LLD around whole-visit revisions. Before presenting it, per the skill's Phase 2 step I ran an edge-case probe on this LLD's own gaps:

- **3+ way competition**: if a third submission also names the now-stale base while two others are already competing, does it join the same unresolved set, or does resolution have to happen pairwise first?
- **Resolution's own base**: when a coordinator resolves by submitting a new edit, what base revision does that submission name — the stale one, one of the competing revisions, or none? The current draft doesn't say.
- **Editing into a pending conflict**: can a worker fetch and edit a visit that already has unresolved competing revisions, producing a third competing branch, or should retrieval block/warn before they start?
- **Idempotency across competition**: if a submission becomes a competing revision and the tablet retries it later (e.g. after a sync hiccup), does the idempotency key still return the original acceptance result even though the visit's current revision has since moved?
- **Revision numbering races**: two submissions naming the same base can arrive concurrently — does revision-number assignment need to be atomic/transactional to avoid both being treated as advancing directly?

I didn't resolve these in the doc — they're yours to triage against the draft below.

---

**Decision doc**: `docs/intent/record-store/decisions/concurrent-visit-edits.md` — full writeup of both options, the criteria (silent-miscombination risk, coordinator workload, maintenance burden, export readiness, sync footprint), why whole-visit revisions wins, and when field-aware merge would be worth revisiting.

**LLD** (`docs/intent/record-store/record-store-design.md`): added revision-number semantics (base-matches-current → direct advance; base-behind-current → competing revision held for a coordinator), the submission envelope, current-state retrieval, the unresolved-work representation, the resolution operation, a Decisions & Alternatives row linking the decision doc, and updated downstream-contract obligations for tablet-sync and review-export.

**HLD**: record-store's state now reads "concurrency resolved (whole-visit revisions)."

Let me know:
1. Numbered feedback on the LLD/decision doc, or approval to proceed, and
2. How you want to triage the five edge cases above (fold into this LLD now, defer as open questions, or something else) before I move to the EARS spec update (Phase 3).