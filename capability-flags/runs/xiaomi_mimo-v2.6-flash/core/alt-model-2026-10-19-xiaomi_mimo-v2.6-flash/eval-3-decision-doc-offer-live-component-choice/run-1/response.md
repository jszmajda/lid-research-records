**Phase 1 — HLD check (complete). Stopping for your review.**

The HLD exists at `docs/high-level-design.md`, covers the domain of this change, and already places the concurrency mechanism under record-store rather than at the root — so your selection is an LLD-level choice, not an architectural HLD revision. No new tenets are implicated; the existing ones (don't silently discard edits; keep the export path inspectable) already lean this direction.

Two HLD statements went stale the moment you chose. I updated them in place:

1. **Architecture table status** for record-store: `Drafted; concurrency choice open` → `Drafted; concurrency policy selected, contract in progress`.
2. **Dependency paragraph**: now says record-store has selected its policy and is completing the contract; tablet-sync and review-export wait on that completed contract rather than on an unresolved choice. The mechanism's substance stays in the record-store LLD.

**One decision-doc offer before Phase 2:** the whole-visit-revisions vs. field-aware-merge choice clears the earns-its-place bar — a cold reader would question "why not auto-merge disjoint fields?", the tradeoffs run on multiple criteria (review workload vs. merge-rule maintenance vs. scientific-relationship safety), and tablet-sync and review-export will both be sized around the result. Options:

- **A. Full decision doc** at `docs/intent/record-store/decisions/` (both options laid out so the judgment can be re-run later), linked from the LLD's Decisions table.
- **B. Decisions-table row only** in the record-store LLD — one line of rationale.

Which would you like, and shall I proceed to Phase 2 (finish the record-store LLD around whole-visit revisions: submission envelope with base revision IDs, competing-revision representation, resolution operation, plus an LLD-level edge-case probe)?