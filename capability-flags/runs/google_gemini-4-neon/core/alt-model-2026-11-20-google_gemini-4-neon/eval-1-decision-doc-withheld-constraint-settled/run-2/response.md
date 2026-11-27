Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (recording the backend and staging-swap choices in `Decisions & Alternatives`) and removed the stale "remains open" note in `docs/high-level-design.md`. No changes were needed in `certificates`.

### Phase 2 Output — `docs/intent/registry/registry-design.md`

- **Architecture & Storage**: Private local SQLite database opened read-only for lookups, with `snapshot_metadata` (`snapshot_date`, `schema_version`) and `equipment_records` (`normalized_serial` PRIMARY KEY, `serial_number`, `equipment_description`, `calibration_date`, `due_date`).
- **Snapshot Import**: Verify signature with the bundled public key, validate schema version, build a staging SQLite database on the same filesystem inside a transaction (enforcing unique normalized serial numbers), flush/close, and atomically swap into place. On any failure, remove the staging file and leave the active snapshot untouched.
- **Lookup Behavior**: Trim surrounding whitespace and uppercase ASCII letters (preserving punctuation), query `equipment_records` by `normalized_serial`, and return `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Recorded the local SQLite backend (eliminating network-backed alternatives under the HLD's offline kiosk constraints) and staging-file atomic activation.

### Phase 2 Edge-Case Probe (for triage: specify in LLD vs. defer as open questions)

1. **First-run / no active snapshot**: What happens when `findBySerial(serial)` is called before any snapshot has ever been imported, given the return type only has `Found(record, snapshotDate)` and `NotFound(snapshotDate)`?
2. **Concurrent lookups during atomic swap & SQLite journal mode**: What happens if a read-only handle is open during an atomic swap (unlinked inode vs. reopening, and avoiding WAL/journal sidecar mismatch on file rename)?
3. **Interrupted import cleanup & concurrent imports**: What happens to orphaned staging files after a crash/power loss, and what happens if a second import is triggered while one is already in progress?
4. **Older or same-date snapshots**: What happens when an incoming signed snapshot has a `snapshot_date` older than or equal to the active snapshot (allow, reject, or warn)?
5. **Record validation & empty snapshots**: What happens when a record has missing/null/empty fields, non-standard date formats, or unknown extra JSON fields—and what happens when a valid signed snapshot has zero records?
6. **Lookup input edge cases**: What happens when `findBySerial(serial)` receives an empty/whitespace-only string or non-ASCII characters (`NotFound(snapshotDate)` vs. validation error)?
7. **Corrupt or unreadable active database**: What error shape and recovery path apply if the active SQLite file is corrupt, missing, or fails I/O during lookup?
8. **Import interface & disk-space exhaustion**: What is the expected import entry point, success result, and structured error shape (including insufficient free disk space for both active and staging databases)?

Please review the updated `registry-design.md` and let me know which probe items (by number) you want resolved in the LLD vs. deferred, and whether we are approved to proceed to Phase 3 (`registry-specs.md`).