**Phase 2 stop — Registry LLD, for your review**

Here is the updated `docs/intent/registry/registry-design.md`. The backend is now settled as local embedded SQLite; the placeholder language is gone.

---

**What changed from the draft:**

- Import sequence is now fully specified: signature → schema → uniqueness → build temp index → atomic rename → discard temp on failure.
- Index structure is spelled out: a `records` table (serial as pre-normalized PK, description, calibration_date, due_date) and a `meta` table (snapshot_date, schema_version).
- Lookup now specifies the no-snapshot case: `NotFound` with a null snapshot date.
- Decisions table records the SQLite choice and its rationale — the HLD tenet eliminates both network-dependent options, so the choice lands as obvious to a cold reader; a full decision doc isn't warranted.
- Three deferred open questions are named explicitly.

---

**LLD-level edge-case probe — gaps to triage:**

1. **Concurrent imports.** Two import calls overlap: the temp file path is unspecified, so two callers could write to the same temp path and collide. Is a per-import unique temp path (e.g., using a nonce) the right fix, or is import serialized by the application layer above this node?

2. **Uniqueness check normalized vs. raw.** The Decisions table says duplicate detection runs on the normalized key. If snapshot records for `SN-001` and `sn-001` are intended as distinct (case-sensitive equipment IDs), normalizing before the uniqueness check would falsely reject the snapshot. Is case-normalization always safe for serial numbers in this domain, or is it possible for two records to differ only in case and be legitimately different?

3. **Null snapshot date in callers.** `findBySerial` returns null snapshot date before any import. The certificates node receives this result — does it handle a null date gracefully, or does it expect a date string to always be present? The certificates LLD should probably address this; flagging as a cross-segment cascade question.

4. **Index file schema versioning.** The `meta` table stores the snapshot's schema version, but nothing specifies the SQLite schema's own version. If a future software update changes the table layout, how is an old index file detected and rejected/rebuilt?

5. **Failure partway through index build.** If the process is killed after the temp file is created but before the rename, the temp file is orphaned. Should the import step clean up orphaned temp files at the start of the next import?

---

Please review the LLD and triage the probe gaps — which to fix now vs. defer. On your go-ahead I'll move to Phase 3 (EARS specs).