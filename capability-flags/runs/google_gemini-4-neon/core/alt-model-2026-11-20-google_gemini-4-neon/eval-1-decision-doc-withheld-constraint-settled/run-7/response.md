Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (and updated the stale "private lookup backend remains open" note in `docs/high-level-design.md` to stay coherent).

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot delivered on approved USB media contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Registry data is read-only on the kiosk and operates entirely from local files with no runtime network access.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `description`, `calibrationDate`, `dueDate`) and result types are fixed. The certificates node uses only this interface and does not access registry storage directly.

Snapshot validation, local index construction, activation, and lookup are encapsulated inside this node using an embedded SQLite database stored on the kiosk's local filesystem. Each active snapshot is represented by a self-contained SQLite database file holding both the indexed equipment records and the snapshot metadata.

## Local SQLite Index

Each snapshot database contains two tables:

- `metadata`: single row storing `snapshot_date`, `schema_version`, and `manifest_digest`.
- `records`: one row per equipment item with `normalized_serial TEXT PRIMARY KEY`, `serial TEXT NOT NULL`, `description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, and `due_date TEXT NOT NULL`.

Indexing on `normalized_serial` supports predictable single-key lookups over ~90,000 records within the 250 ms latency target and 4 GB RAM budget. Lookups open the active database in read-only mode so queries cannot mutate snapshot state.

## Snapshot Import & Activation

Importing a USB snapshot proceeds in four stages so partially imported or invalid data is never exposed:

1. **Manifest and signature verification**: Verify the snapshot signature against the bundled public key and reject unsupported schema versions before building an index.
2. **Staged SQLite build**: Create a new staging SQLite file in the local registry data directory. Parse the newline-delimited JSON records inside a single transaction, normalize each serial number, and insert into `records` (relying on the `PRIMARY KEY` constraint to reject duplicate normalized serial numbers). Write the snapshot metadata row into `metadata`, commit, and flush the file to disk before closing.
3. **Atomic activation**: Atomically point the registry at the completed database file on the same filesystem so all records and the new `snapshotDate` become visible together.
4. **Cleanup and failure recovery**: After activation succeeds, remove superseded snapshot database files once no longer in use. If any stage fails (invalid signature, unsupported schema version, malformed record, duplicate serial number, or disk error), delete the staging file, leave the previously active SQLite database untouched, and return a descriptive error.

## Lookup Behavior

Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters; serial-number punctuation remains significant. Query the active SQLite database in read-only mode by `normalized_serial` and read `snapshot_date` from `metadata` on the same database connection so the returned record (or absence of one) and `snapshotDate` always come from the same snapshot. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` otherwise.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks operate offline with no runtime network access and receive updates exclusively via signed USB snapshots, ruling out network-backed directories and cloud search services. Embedded SQLite requires no separate service, delivers predictable sub-250 ms lookups over ~90,000 records within 4 GB RAM, and keeps indexing encapsulated inside the registry node; the trade-off is that each kiosk validates and rebuilds its own index when a snapshot arrives. |
| Snapshot activation | Staged SQLite file with atomic activation | In-place updates to a single mutable database | Building into a separate file guarantees that failed or interrupted imports never corrupt or partially expose the active snapshot, and keeps read-only lookups isolated from import writes. |
```

### Phase 2 LLD-Level Edge-Case Probe

A blind subagent review of `registry-design.md` surfaced these gaps for triage:

1. What happens when `findBySerial(serial)` is called before any snapshot has been activated, or when the active SQLite database file is missing, unreadable, or corrupt on disk, given that the API only defines `Found(record, snapshotDate)` and `NotFound(snapshotDate)`?
2. What happens when a validly signed snapshot is imported whose `snapshot_date` is older than or equal to the currently active snapshot, or whose `manifest_digest` matches the active snapshot?
3. What happens when `findBySerial(serial)` is in flight during atomic activation and Stage 4 cleanup of superseded snapshot files, or when two snapshot imports are initiated concurrently?
4. What happens when the kiosk crashes or loses power mid-import (leaving orphaned staging files or SQLite journal/WAL sidecars) or between atomic activation and cleanup, and how does the registry determine the authoritative active database and reclaim leftover files on restart?
5. What happens when the USB snapshot payload is modified, truncated, or removed between Stage 1 (manifest and signature verification) and Stage 2 (parsing newline-delimited JSON into the staging SQLite file)?
6. What happens when a serial number (in a snapshot record or passed to `findBySerial`) is empty or whitespace-only after trimming, contains internal whitespace or control characters, or contains non-ASCII letters or canonically equivalent Unicode sequences?
7. What happens when a snapshot contains zero equipment records, or when a record has empty string values, extra/unknown JSON fields, or malformed or inconsistent `calibrationDate`/`dueDate` values (such as non-ISO formats or `dueDate` preceding `calibrationDate`)?

---

**Phase 2 stop:** Please review the LLD above and let me know:
- Which of the probe items (1–7) you want resolved in `registry-design.md` now vs. deferred as open questions.
- Any edits to the LLD before we move to Phase 3 (`registry-specs.md`).