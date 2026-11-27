Updated `docs/intent/registry/registry-design.md` with the local embedded SQLite index design (and updated the stale "remains open" note in `docs/high-level-design.md` to keep the HLD coherent).

### Updated Registry LLD (`docs/intent/registry/registry-design.md`)

- **Storage & Schema**: Self-contained read-only SQLite database per active snapshot with `snapshot_meta` (`snapshot_date`, `schema_version`, `record_count`) and `equipment` (`normalized_serial TEXT PRIMARY KEY`, `serial`, `description`, `calibration_date`, `due_date`).
- **Snapshot Import**: Verify signature manifest against the bundled public key → validate schema version and snapshot date → stream NDJSON records into a staged SQLite database on the same filesystem inside one transaction (enforcing normalized serial uniqueness via primary key) → flush, close, and atomically replace the active database. Any failure deletes the staging file, keeps the previous snapshot active, and returns a descriptive error.
- **Lookup Behavior**: Trim surrounding whitespace and uppercase ASCII letters (preserving punctuation), query `equipment` by `normalized_serial` and read `snapshot_date` from `snapshot_meta`, returning `Found(record, snapshotDate)` or `NotFound(snapshotDate)` with no writes or network access.
- **Decisions & Alternatives**: Recorded rows for **Lookup backend** (local embedded SQLite vs. on-site HTTPS directory / managed search service), **Atomic snapshot activation** (staged SQLite swap vs. in-place rebuild), and **Serial normalization timing** (import-time normalization as `PRIMARY KEY` vs. query-time/collation).

### Phase 2 LLD Edge-Case Probe

Please triage which of these internal registry gaps to specify in the LLD now vs. defer as open questions:

1. **Cold start (no active snapshot):** What happens when `findBySerial(serial)` is called before any snapshot has been imported, given both `Found` and `NotFound` require a `snapshotDate`?
2. **Corrupt or unreadable active database:** What happens when `findBySerial(serial)` encounters a missing, unreadable, or corrupted SQLite file (or empty `snapshot_meta`), since lookup has no error variant?
3. **Empty or whitespace-only lookup input:** Does `findBySerial("")` / `findBySerial("   ")` return `NotFound(snapshotDate)` or an invalid-input error?
4. **Malformed records and empty snapshots:** How should import handle NDJSON lines with missing/empty fields, malformed dates, or unknown extra fields—and is a validly signed snapshot with zero records accepted or rejected?
5. **Snapshot date ordering (rollback / replay):** Should importing a validly signed snapshot whose `snapshot_date` is older than (or equal to) the active snapshot be allowed or rejected?
6. **Reader handle lifecycle and concurrent imports:** How are active read-only SQLite handles updated or drained across the atomic swap, and what happens if two imports are triggered concurrently?
7. **Mid-import crash and stale staging cleanup:** When and how are leftover staging databases or SQLite journal/WAL sidecar files cleaned up after a power loss or crash?
8. **USB disconnect / TOCTOU and disk space:** Should the snapshot be verified and read from a local copy (preventing USB disconnect or modification between verification and streaming), and how is insufficient disk space for staging handled?
9. **Import API and error shapes:** What input contract does import accept (e.g., snapshot directory/archive path vs. manifest + NDJSON paths), and what error categories/shapes should it return?

**Phase 2 review:** Please review `docs/intent/registry/registry-design.md` and let me know how you want to triage items 1–9 (or approve as-is) before we move to Phase 3 (EARS specs).