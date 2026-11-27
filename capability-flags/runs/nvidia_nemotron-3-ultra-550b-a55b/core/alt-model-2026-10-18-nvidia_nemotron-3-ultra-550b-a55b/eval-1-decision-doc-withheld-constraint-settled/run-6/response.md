**Phase 2 complete — LLD updated with SQLite index decision.**

---

### Summary of Changes to `docs/intent/registry/registry-design.md`

1. **Architecture** — Confirmed local embedded SQLite index as the lookup backend; removed the three-candidate phrasing.
2. **SQLite Index Backend** — Added section detailing schema, build process, file size/build time targets.
3. **Snapshot Import** — Extended with concrete SQLite build steps (staging → validate → build → verify → atomic swap).
4. **Lookup Behavior** — Added SQLite-specific semantics (normalization layer, BINARY collation, latency target).
5. **Decisions & Alternatives** — Recorded the backend choice with the three alternatives and rationale.
6. **Open Questions** — Marked backend as resolved; deferred progress reporting and incremental updates.

---

**STOP for your review.** Please confirm the LLD reads correctly, or note any adjustments before I proceed to Phase 3 (EARS specs).