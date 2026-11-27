**Pre-flight:** HLD, LLD, and REC specs were mutually coherent as of last session's open choice. Your selection makes two docs stale in the same way: the HLD's record-store status line and dependency paragraph, and the record-store LLD's "Open Design Choice" section. The LLD rewrite is Phase 2 work; the HLD fixes are this phase's.

**Phase 1 — HLD check.** `docs/high-level-design.md` exists and covers the change; selecting whole-visit revisions resolves a choice the HLD deliberately delegated to record-store, so the architecture itself is unchanged. Two edits made to keep the HLD true:

1. Architecture table, record-store row — State changed from `Drafted; concurrency choice open` to:
   `Drafted; whole-visit revisions selected`
2. Dependency paragraph after the table — "unresolved choice" is no longer true; now reads:
   > The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and review-export depend on that node's contract: it determines submission metadata, the shape of review work, and which record states can enter an export. Those two designs must wait for that contract.

Nothing else in the HLD changed. Tablet-sync and review-export are untouched, per your scoping.

**Stop — Phase 1 review.** Numbered, so you can reply by number:

1. Approve the HLD update (or send corrections), and I'll proceed to Phase 2: completing the record-store LLD — submission envelope, current-state response, competing-revision representation, resolution operation, a Decisions & Alternatives row, plus an edge-case probe whose gaps I'll bring back to you.
2. Your rationale ("a bigger review queue over merge rules that can combine scientifically related edits without noticing") clears the bar for a full decision doc — the choice stays live for a cold reader, and tablet-sync and review-export will both be sized around it. Record it as `docs/intent/record-store/decisions/whole-visit-revisions.md`, linked from the LLD's Decisions row? Or a Decisions row only? (Either way the rationale lands in the LLD.)
3. That rationale also reads like a tenet leaning future automation decisions (any later auto-merge, dedup, or suggestion feature). Add to the HLD's Tenets — e.g. "Prefer an auditable review queue over automated combination of edits whose relationships the system cannot verify"? Or keep it as decision rationale only?