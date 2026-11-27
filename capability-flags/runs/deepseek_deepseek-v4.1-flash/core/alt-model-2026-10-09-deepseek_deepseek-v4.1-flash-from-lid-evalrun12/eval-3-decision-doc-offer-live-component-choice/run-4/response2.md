Wrote `docs/intent/record-store/decisions/whole-visit-revisions.md` (node: `record-store`) and linked it from the LLD's Decisions & Alternatives row.

The doc's shape:

- **Context** — why the store must define a current record without trusting arrival order, and that the choice fixes the envelope, review shape, and export eligibility.
- **Decision Elements** — five weighted criteria: preserves whole-visit scientific intent (major), bounds coordinator review work (major), implementation/maintenance burden (major), export provenance inspectable (moderate), submission/offline cost (minor). One latent criterion surfaced and weighed: whether the mechanism commits the team to rules whose correctness it cannot establish.
- **Options in the Domain** — whole-visit revisions and field-aware three-way merge, each at its strongest: description, a concrete worked example, and a per-criterion verdict. Field-aware merge is represented as its advocate would: it wins review workload and export readiness and keeps unrelated edits out of review.
- **Selection** — names the three tenets the decision turns on and the one it leans against, and records that the choice is revisitable: a later merge layer would require extending the envelope (base snapshots / structured changes), which whole-visit submissions do not carry.
- **Downstream obligations** — spelled out for tablet-sync (retain and send base revision IDs; show pending competing revisions) and review-export (comparison workflow; hold unresolved visits out of the CSV).

Still open from the last stop: **which LLD edge-case probe gaps do you want folded in now?** My recommendation was #3 (multi-fork enumeration), #4 (absent base on a populated visit / base on an empty visit), #5 (dangling or foreign base), #7 (retry result after the visit changed), and #11 (error/response shapes) — those gate writing specs and tests; #6 (idempotency-key scope) and #12 (receipt-time ties) are your call. I have not touched `record-store-specs.md` or anything in tablet-sync or review-export yet.

Tell me the gap triage and I'll fold in the chosen ones, then move to Phase 3 (EARS).