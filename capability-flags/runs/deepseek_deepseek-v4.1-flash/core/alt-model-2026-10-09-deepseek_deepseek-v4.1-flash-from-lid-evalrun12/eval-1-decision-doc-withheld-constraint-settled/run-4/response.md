I've settled the backend and finished the Phase 2 (LLD) pass. Here's the stop for your review.

**Files changed**

- `docs/intent/registry/registry-design.md` — rewrote the backend-open sections: Architecture now names the local embedded SQLite index; Snapshot Import builds a fresh separate database file and activates only after validation + construction succeed; a new **Index and Lookup** section specifies the normalized-key index and identical normalization at build and lookup; a new **Activation** section specifies swap-after-success; added the **Decisions & Alternatives** table with the backend choice.
- `docs/high-level-design.md` — the registry bullet said "its private lookup backend remains open"; updated to name the SQLite index, since that line is now stale.

The certificates node needed no change: it only sees `findBySerial`, and the interface is unchanged.

**LLD-level edge-case probe — gaps to triage**

1. **Pre-snapshot state.** What does `findBySerial` return when no snapshot has ever been imported (no active index)? No spec or design text covers it.
2. **Duplicate definition (spec fork).** REG-003 rejects "duplicate serial numbers" — judged on the raw value or the normalized one? Under this index two records differing only in case/surrounding whitespace collide on the same key. This needs your ruling before tests.
3. **Concurrent imports.** Nothing says whether a second import may start while one is in progress, or that imports are serialized.
4. **Partial-index cleanup / space.** If construction fails midway (disk full, malformed record), is the partial DB file discarded? Snapshot (≤150 MB) + new index must both fit on the kiosk during import.
5. **Normalization scope.** REG-001 covers surrounding whitespace and ASCII case; the design says punctuation is preserved but is silent on *internal* whitespace and non-ASCII letters.
6. **Rebuild cost.** Lookup has a 250 ms goal; rebuild time and index footprint at import are unbounded in the text.

**Decision-doc offer**

The backend choice stayed genuinely live across three credible options traded against several criteria, and both the registry design and kiosk operations are now sized around it. Shall I record it as a full decision doc at `docs/intent/registry/decisions/lookup-backend.md`, with the table row as the alternative? (I declined to write it unasked — a row may be enough.)

**Please tell me:**
- Which of the six gaps to fix in the LLD now vs. defer as open questions — especially #2, which is a spec fork I shouldn't resolve for you.
- Whether to write the decision doc.
- Approval to cascade into Phase 3 (EARS) once the above is settled.