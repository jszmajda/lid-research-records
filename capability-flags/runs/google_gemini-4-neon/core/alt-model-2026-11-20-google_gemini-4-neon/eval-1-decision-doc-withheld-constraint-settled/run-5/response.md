Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (and updated the matching Registry line in `docs/high-level-design.md` so it no longer marks the backend as open; `certificates` is unaffected).

### Updated Registry LLD (`docs/intent/registry/registry-design.md`)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `calibrationDate`, `dueDate`, `description`) and result types are fixed; the certificates node uses only this interface.

Lookups are backed by a local embedded SQLite database stored on the kiosk. Snapshot validation, index construction, atomic activation, and read-only querying all live inside this node.

## Storage & Schema

Each validated snapshot is compiled into a self-contained SQLite database file on local kiosk storage:

- `records`: keyed by `serial_normalized` (`TEXT PRIMARY KEY`), storing original `serial`, `calibration_date`, `due_date`, and `description`.
- `snapshot_meta`: single row storing `schema_version`, `snapshot_date`, and the snapshot manifest digest.

SQLite serves point queries directly through the `serial_normalized` B-tree index without loading all ~90,000 records into memory, meeting the 250 ms lookup latency and 4 GB RAM targets.

## Snapshot Import

1. Verify the snapshot signature manifest using the bundled public key and confirm the schema version is supported before parsing records.
2. Create a staging SQLite database file on the same local filesystem as the active database.
3. Stream newline-delimited JSON records into `records` within a single transaction, normalizing each serial number (trim surrounding whitespace, uppercase ASCII letters; preserve punctuation) and enforcing uniqueness on `serial_normalized`.
4. Write `snapshot_meta`, commit the transaction, flush (`fsync`) the staging file, and run SQLite integrity verification.
5. Activate the staged database atomically (atomic filesystem rename/pointer swap) so readers see either the complete previous snapshot or the complete new snapshot, never a partial import.

If any step fails — invalid signature, unsupported schema version, malformed record, duplicate serial number, or I/O failure — delete the staging file, leave the active database untouched, and report an actionable error.

## Lookup Behavior

Open the active SQLite database in read-only mode. Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters while keeping serial-number punctuation significant. Execute an indexed point lookup on `records.serial_normalized` and read `snapshot_date` from `snapshot_meta`. Return `Found(record, snapshotDate)` when a row matches or `NotFound(snapshotDate)` when none matches, always including the active snapshot date.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, managed search service | Kiosk tenets prohibit runtime network access and external services; an embedded SQLite B-tree index resolves ~90,000-record lookups within 250 ms and 4 GB RAM with no background service to operate and keeps storage private to the registry. |
| Snapshot activation | Build staged SQLite file and swap atomically | In-place update of active database | Ensures a failed import or mid-import crash leaves the previous valid snapshot intact and prevents lookups from observing partially imported records. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs in `docs/intent/registry/registry-specs.md`), please triage which of these internal gaps to resolve in the LLD now vs. defer as open questions:

1. **Cold start / unreadable active DB**: What happens when `findBySerial(serial)` is called before any snapshot has been imported, or if the active SQLite file is missing/corrupt? Both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require an active `snapshotDate`.
2. **Rollback, replay, and empty snapshots**: What happens when a validly signed snapshot has a `snapshot_date` older than or equal to the active snapshot, or contains zero records — accept or reject?
3. **Record and query validation**: What happens when a snapshot record has an empty/whitespace-only `serial`, missing/unparseable dates, or `dueDate < calibrationDate`, or when `findBySerial` receives an empty/whitespace-only string?
4. **Concurrency and SQLite journal mode during swap**: What happens when `findBySerial` holds an open read-only connection during the atomic swap (especially on Windows vs. Linux file-locking semantics), or when two imports run concurrently? Should the staged DB explicitly use a single-file journal mode (e.g., `DELETE`/non-WAL) so no `-wal`/`-shm` sidecars linger across swaps?
5. **Crash recovery / orphaned staging files**: What happens if the kiosk loses power mid-import before the error handler runs, leaving orphaned staging files on disk?
6. **Import API and error shapes**: What is the import entry point signature, input layout (single bundle vs. separate manifest + NDJSON paths), and structured error shape (e.g., distinct error kinds, line number on malformed record, offending serial on duplicate)?
7. **USB removal, TOCTOU, and size/space limits**: What happens if the USB drive is removed mid-import, if a snapshot exceeds 150 MB or free disk space cannot hold both active and staged DBs, or if the USB file changes between signature verification and NDJSON streaming?

Please review the LLD above, let me know any edits and how you'd like to triage items 1–7, and confirm when you're ready to proceed to Phase 3 (EARS specs).