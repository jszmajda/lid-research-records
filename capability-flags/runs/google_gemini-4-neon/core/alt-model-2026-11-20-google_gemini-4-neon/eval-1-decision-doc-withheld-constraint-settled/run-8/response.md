Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (with a **Decisions & Alternatives** row recording the backend and staged-activation choices) and updated the registry summary line in `docs/high-level-design.md` so it no longer marks the backend as open. `docs/intent/certificates/` is untouched because `findBySerial(serial)` and its result types are unchanged.

### Updated `docs/intent/registry/registry-design.md`

- **SQLite Storage & Schema**: Each snapshot builds into its own SQLite file with a single-row `metadata` table (`snapshot_date`, `schema_version`) and an `equipment` table keyed on `normalized_serial TEXT PRIMARY KEY` (`serial`, `description`, `calibration_date`, `due_date`).
- **Snapshot Import**: Verify signature with bundled public key → validate `schema_version` → stream NDJSON into a staging SQLite DB inside one transaction (normalizing serials and rejecting malformed records or duplicate `normalized_serial`s) → write `metadata`, commit, check integrity, fsync → activate atomically → on any failure, remove staging file, preserve active snapshot, and return an actionable error.
- **Lookup Behavior**: Trim surrounding whitespace and uppercase ASCII letters (punctuation preserved), query active read-only SQLite DB by `normalized_serial` and read `snapshot_date` from `metadata`, return `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Recorded the local embedded SQLite backend (vs. on-site HTTPS directory and managed search service) and staged-file atomic swap (vs. in-place mutation).

### Phase 2 LLD Edge-Case Probe (for triage)

Please indicate which of these to **resolve in the LLD** now vs. **defer as open questions**:

1. **Cold-start / no active snapshot**: What happens when `findBySerial` is called before any snapshot has been imported (or if the active DB file is missing), since both `Found` and `NotFound` require a `snapshotDate`?
2. **Atomic activation with in-flight readers & concurrent imports**: What swap mechanism and connection lifecycle should be used when a `findBySerial` query holds an open read-only SQLite handle during activation, or when two imports run concurrently?
3. **Crash recovery, disk space, and cleanup**: What happens on power loss mid-import or right after activation (orphaned staging or prior-version DB files), or when local disk runs out of space while building the staging DB?
4. **Snapshot date ordering**: What happens when a validly signed snapshot has a `snapshot_date` older than (or equal to) the currently active snapshot—allow rollback or reject?
5. **Runtime corruption of the active DB**: What happens if the active SQLite file is corrupted, unreadable, or missing its `metadata` row at startup or during `findBySerial`?
6. **Input & record edge cases**: What happens for an empty/whitespace-only serial, non-ASCII characters/whitespace, extra unknown JSON fields, empty strings vs. missing fields, inverted dates (`due_date < calibration_date`), or a validly signed snapshot with zero records?
7. **Import API & error contract**: What should the import entry-point signature and structured error variants be across each failure stage (signature, schema, malformed JSON, duplicate serial, integrity check, I/O)?

Review the updated `registry-design.md` and let me know your triage on 1–7 and whether we're approved to proceed to Phase 3 (EARS specs in `docs/intent/registry/registry-specs.md`).