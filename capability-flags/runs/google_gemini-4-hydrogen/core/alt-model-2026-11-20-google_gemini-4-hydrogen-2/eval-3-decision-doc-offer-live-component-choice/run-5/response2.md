Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

- **Context & Decision Elements**: Frames the 24-worker / 12-tablet / 48-hour offline setting and evaluates options against four criteria—*Preservation of whole-visit scientific intent* (**major**, from HLD inspectability tenet & non-goal), *Operational simplicity for a two-coordinator team* (**major**, from HLD two-coordinator tenet), *Coordinator review queue volume* (**moderate**), and *Downstream implementation and storage footprint* (**minor**).
- **Options in the Domain**: Gives full descriptions and per-element fit verdicts for both **Whole-visit revisions** and **Field-aware three-way merge**.
- **Selection**: Records why whole-visit revisions wins on both major criteria, why field-aware three-way merge remains a credible alternative (revisitable without losing raw submissions if disjoint-edit review volume overwhelms the two coordinators), and what `tablet-sync` (`baseRevisionId`, `idempotencyKey`, `unresolved` status UX) and `review-export` (excluding `unresolved` visits from CSV, side-by-side whole-visit comparison, `expectedCompetingRevisionIds` guard) must accommodate.

---

Before we move to **Phase 3** (updating `docs/intent/record-store/record-store-specs.md`), please confirm:
1. Any changes to `docs/intent/record-store/decisions/concurrent-visit-edits.md` or `docs/intent/record-store/record-store-design.md`.
2. How you'd like to triage the 8 edge-case questions from the Phase 2 probe above (which to resolve in `record-store-design.md` now vs. defer).
3. Approval to proceed to Phase 3.