**Phase 1 — HLD check (complete).** The project is already LID-configured (`CLAUDE.md` → Mode: Full, v1.4.0), `docs/high-level-design.md` exists, and it already covers this domain. The architecture is unchanged by the concurrency selection, so the HLD needed only to stop describing the choice as open. Updated `docs/high-level-design.md`:

- **Approach** (line 11) now states the approach-level commitment: *"Concurrent edits to the same visit are reconciled by coordinator review of whole-visit revisions, never by automatic field-level merging."*
- **Architecture table** (line 18): record-store state is now `Drafted` (was `Drafted; concurrency choice open`).
- **Architecture note** (line 22): now reads that tablet-sync and review-export depend on *record-store's contract* (submission metadata, review-work shape, export-eligible states) rather than on an unresolved choice.

I deliberately did **not** name the mechanism in detail here: the substance of the choice (revision lineage, unresolved-work shape, resolution operation) lives in record-store, and the HLD's own note says the mechanism belongs to that node. It will be recorded in that node's Decisions table, with rationale.

Two things are yours to rule on before I move to Phase 2 (LLD):

1. **Tenet candidate.** The HLD's tenets currently stop at "Do not silently discard a submitted edit" — that covers preservation, but not your stated reason for preferring a bigger review queue: *merge rules that can combine scientifically related edits without noticing*. A candidate tenet, generalizing past this one decision:
   > **Review over silent combination.** When a mechanism could reconcile two submissions automatically, prefer a visible review queue over a rule that combines them, unless the combination rule is provably safe for the fields it touches.

   The defensible opposite ("minimize coordinator load by automatic combination where the rules say it's safe") is credible enough for this to be a real tenet rather than a platitude. Accept, reword, or reject?
2. **Review instrument for the remaining phases.** Default is that you read each phase's output at its stop (Phase 2 LLD, Phase 3 EARS, Phase 4 edge audit, then tests and code). If you'd rather have a delegated inspector or a zero-context reader on the design phases, say so and I'll dispatch one at each stop instead — the stops themselves still happen.

Also worth flagging now, since it shapes Phase 2: **there is no code in this repository at all** — `docs/` is the only content. Phases 5 and 6 (tests-first, then implementation) therefore mean creating the implementation from scratch, which needs a stack and language decision that no document currently makes. I'll raise that when we reach those phases rather than assume it.