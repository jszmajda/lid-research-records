Updated `docs/high-level-design.md` and `docs/intent/registry/registry-design.md` to complete **Phase 2 (LLD)** for the local embedded SQLite index:

- **`docs/high-level-design.md`**: Updated the Registry summary to reflect local SQLite indexing instead of an open backend.
- **`docs/intent/registry/registry-design.md`**:
  - **Storage and Schema**: Defined `registry.db` (active) and `registry.staging.db` (same-filesystem staging) with `snapshot_meta` and `equipment_records` (`serial_normalized` primary key).
  - **Snapshot Import**: Specified signature/schema verification, streaming NDJSON parse inside a single transaction, `serial_normalized` uniqueness enforcement, atomic rename activation, and failure cleanup.
  - **Lookup Behavior**: Specified read-only SQLite lookup by `serial_normalized` plus `snapshot_date` retrieval.
  - **Decisions & Alternatives**: Recorded the SQLite selection and rationale against the offline kiosk tenet and 250 ms / 4 GB RAM goals.

### LLD Edge-Case Probe (Phase 2)

Please triage which of these gaps to resolve in `registry-design.md` now versus defer to `Open Questions & Future Decisions`:

1. **Initial state (no active snapshot)**: What does `findBySerial(serial)` return before any snapshot has ever been imported (`registry.db` missing), given `Found` and `NotFound` both require `snapshotDate`?
2. **Lookup during atomic rename**: If `findBySerial` holds or opens a read-only connection concurrently with the rename of `registry.staging.db` to `registry.db`, how is connection reopen/invalidation handled?
3. **SQLite journal/WAL sidecar files**: How are `-wal`, `-shm`, or `-journal` files prevented or checkpointed/removed before rename so stale sidecar files cannot corrupt a newly activated `registry.db`?
4. **Concurrent imports**: Are concurrent snapshot imports serialized (e.g., via lock) or rejected if one is already in progress?
5. **Empty or non-ASCII lookup input**: What happens when `findBySerial` receives an empty/whitespace-only string or non-ASCII characters?
6. **Malformed or incomplete NDJSON records**: How are blank lines, invalid JSON, missing/null fields, or a `serial` that normalizes to empty handled?
7. **Zero-record snapshot or metadata mismatch**: Is a signed snapshot with zero records valid, and what if `snapshot_date` or `record_count` is missing or mismatches the stream?
8. **Date format validation**: What date format is required for `snapshot_date`, `calibrationDate`, and `dueDate`, and are invalid or inverted dates (`dueDate < calibrationDate`) rejected on import?
9. **Snapshot downgrade**: If a valid signed snapshot has an older `snapshot_date` than the currently active `registry.db`, is it accepted or rejected?
10. **Returned `serial` representation**: In `Found(record, snapshotDate)`, does `record.serial` return `serial_raw` or `serial_normalized`?
11. **Corrupt or unreadable `registry.db` on lookup**: What error shape does `findBySerial` produce if `registry.db` exists on disk but is corrupt or unreadable?
12. **Import interface and error shape**: What is the import entry point's input shape (bundle path/stream) and error shape?
13. **Disk space exhaustion / cleanup failure**: How are disk-full errors during staging or failures deleting a stale `registry.staging.db` surfaced?

Review the updated `docs/intent/registry/registry-design.md` and let me know which items above to incorporate or defer, and whether we are approved to proceed to **Phase 3 (EARS specs)**.