Coherence pre-flight (new session): the HLD and LLD still described the concurrency choice as "open", and the six specs (REC-001…006) are deliberately policy-agnostic — REC-004 still reads "regardless of the concurrency policy's outcome". No tests or code exist yet. I treated whole-visit revisions as settled, not re-opened, and fixed the stale wording rather than re-sketching options.

Done this pass — the design rung:

- `docs/intent/record-store/decisions/concurrent-visit-edits.md` — the decision doc, written cold. It gives field-aware three-way merge its strongest honest case and states exactly when we'd still choose it (the review queue becoming the binding constraint, a stabilised schema, or every combined record held for whole-visit approval), and spells out what tablet-sync and review-export must accommodate. Placed at the record-store segment, since the HLD assigns the mechanism there — say the word if you'd rather it sit at `docs/decisions/`.
- `docs/intent/record-store/record-store-design.md` — finished LLD: whole-visit revisions, the submission envelope (base revision ID, full payload, idempotency key, author, timestamp), competing-revision and unresolved-work representation, the resolution operation, and the dependent-node contract. The rejected alternative now lives only in the Decisions row, not in body prose.
- `docs/high-level-design.md` — dropped the stale "concurrency choice open / must wait for its contract" wording.

I did **not** add a tenet, open tablet-sync/review-export, or touch specs/tests/code.

Stopping here before the downstream cascade. Numbered rulings I need:

1. **Tenet.** The decision turns on a lean the HLD doesn't currently state — roughly "a larger, fully human-reviewed queue is acceptable; maintained merge rules that can silently combine scientifically related edits are not." Tenets are elicited, not assumed, so I left it out. Shall I add it as a one-line HLD tenet, and where should it rank (higher wins on conflict with "Prefer workflows two coordinators can operate without a dedicated systems administrator")?
2. **LLD edge-case probe finding.** One gap: may a coordinator resolving competing revisions author a new corrected current revision, or only select one of the competing ones? I logged it as *Deferred* to settle with review-export. Fix it in the LLD now, or defer?
3. **Cross-segment pause.** Tablet-sync and review-export stay deferred per your call; their obligations are recorded as cascade notes only. Confirm I should not open those designs yet.
4. **Approve the design rung?** On your word I cascade within the record-store segment: revise the six specs to whole-visit terms and add specs for the envelope / competing revisions / resolution (Phase 3), run the intent-narrowing edge audit (Phase 4), then tests-first (Phase 5) and code (Phase 6) — each with its own stop.