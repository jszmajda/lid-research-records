I updated `docs/intent/registry/registry-design.md` with the local embedded SQLite design (recording the backend choice in its `Decisions & Alternatives` table) and removed the stale `"Its private lookup backend remains open."` sentence from `docs/high-level-design.md` while keeping the SQLite storage details private to the `registry` component. Because `findBySerial(serial)` and its return shape are unchanged, `certificates` is unaffected.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. Registry data arrives on approved USB media as a signed snapshot package containing newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest. Kiosks operate offline with 4 GB of RAM and must resolve lookups across approximately 90,000 records (snapshots up to 150 MB) within 250 ms.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, where `record` carries the equipment serial number, description, calibration date, and due date. The certificates component depends only on this interface; SQLite file paths, schema, and connection handling remain private to the registry component.

The registry maintains a local embedded SQLite database built on the kiosk during snapshot import and queried in read-only mode during lookups. No background server process or runtime network access is used.

## Index Schema and Storage

Each imported snapshot is materialized as a standalone SQLite database file in a registry-owned local data directory:

- **`metadata` table**: single row storing `schema_version` and `snapshot_date`.
- **`records` table**: `serial_number TEXT PRIMARY KEY`, `description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, `due_date TEXT NOT NULL`.

Storing `serial_number` in normalized form as the `TEXT PRIMARY KEY` enforces uniqueness during import and serves lookups via a single B-tree point read without holding the 90,000-record dataset in memory. An active-database pointer file in the same directory identifies the currently active SQLite file.

## Snapshot Import

Import runs against a signed USB snapshot package in four stages:

1. **Manifest and schema check**: Verify the signature manifest over the snapshot contents using the bundled public key and confirm the declared `schema_version` is supported before ingesting records.
2. **Staged index build**: Create a temporary SQLite database file in the local registry directory. Stream NDJSON records line by line inside a single write transaction so memory usage stays bounded well below the 4 GB kiosk limit on snapshots up to 150 MB. Normalize each record's serial number before insertion; any duplicate normalized serial number violates the `PRIMARY KEY` constraint and aborts the import.
3. **Durability and activation**: Commit the transaction, close the write handle, `fsync` the staged database file, atomically replace the active-database pointer to reference the new SQLite file, and swap the in-process read-only database handle so subsequent lookups observe the new snapshot as a whole.
4. **Failure handling and cleanup**: If signature verification, schema validation, JSON parsing, record validation, or SQLite construction fails, delete the staged SQLite file, keep the previously active database active, and return a structured import error identifying the failure reason. Remove superseded database files once no in-flight lookup holds the prior handle.

## Lookup Behavior

Normalize the requested `serial` by trimming leading and trailing whitespace and converting ASCII lowercase letters (`a`–`z`) to uppercase (`A`–`Z`). Internal whitespace and serial-number punctuation remain significant.

Execute a parameterized read-only query (`SELECT serial_number, description, calibration_date, due_date FROM records WHERE serial_number = ?`) against the active SQLite connection alongside the active `snapshot_date`. Return `Found(record, snapshotDate)` when a row matches and `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on each kiosk during snapshot import | On-site HTTPS directory; managed search service; direct scan or full in-memory map of raw NDJSON snapshot | Kiosks operate without a runtime network route, eliminating networked directory and managed search services. Compared with scanning a 150 MB NDJSON file per lookup or parsing 90,000 records into memory on startup, a local B-tree SQLite file keeps resident memory small on 4 GB kiosks, persists across restarts without re-indexing, and resolves point lookups well within 250 ms, trading per-kiosk index build work at USB import time for predictable local reads. |
| Snapshot replacement | Build a separate staged SQLite file and atomically swap the active pointer | Replace rows in place inside a single SQLite database file | Building in a staging file avoids write-lock contention with concurrent lookups and ensures a failed or interrupted 150 MB import leaves the active database file untouched. |
```

---

### Phase 2 LLD Edge-Case Probe (`registry`)

Here are internal component gaps surfaced against `registry-design.md` for triage:

1. **Cold-start state before first import**: What happens when `findBySerial(serial)` is called on a fresh kiosk before any snapshot has been imported, given that both `Found` and `NotFound` require a `snapshotDate`?
2. **Startup recovery and integrity**: What happens on kiosk startup after a power loss when leftover staging files, unremoved superseded SQLite files, or a missing/corrupt active SQLite file or pointer file are present?
3. **Empty/invalid lookup input and read I/O errors**: What happens when `findBySerial(serial)` receives an empty or whitespace-only string, or encounters a local SQLite read error on the active handle?
4. **Import interface and package contract**: What is the concrete import entrypoint signature, expected USB snapshot package layout and signature scheme, and the taxonomy/shape of the structured import error?
5. **Older or same-date snapshot imports**: What happens when a validly signed USB snapshot has a `snapshot_date` older than or equal to the active snapshot—are downgrades and re-imports allowed or rejected, and how are database filenames keyed so re-importing does not collide with the active file?
6. **Normalization details and returned `serial_number` casing**: Does `Found.record.serial_number` return the normalized uppercase string or the raw snapshot string, which whitespace characters are trimmed (ASCII whitespace vs. Unicode whitespace), and are empty normalized serial numbers rejected at import?
7. **Record field and size validation during streaming**: What happens when a signed snapshot has zero records, blank lines, empty strings in `NOT NULL` fields, malformed dates, a payload exceeding 150 MB, or an oversized newline-free line?
8. **USB disconnect or mutation mid-import**: What happens if the USB drive is removed or modified between Stage 1 signature verification and Stage 2 NDJSON streaming (e.g., should verification stream into a local copy or verify content digests while reading)?
9. **Consistent `(connection, snapshot_date)` pairing across swaps**: How are the active read-only SQLite handle and `snapshot_date` paired as one immutable unit so an in-flight `findBySerial` cannot pair a query on the old database with the new `snapshotDate`?
10. **Concurrent imports and handle reclamation**: What happens if a second import starts while one is already in progress, and how are in-flight readers tracked before deleting a superseded SQLite file?
11. **Disk-space exhaustion and pointer `fsync`**: What happens if disk space cannot hold the active database plus the new staged database and journal simultaneously, and does Stage 3 `fsync` both the pointer file and parent directory?

Please review the updated `registry-design.md` and let me know:
1. Any changes you want to the LLD as drafted.
2. Which numbered gaps above we should settle in `registry-design.md` now versus record as deferred under `Open Questions & Future Decisions` before moving to Phase 3 (`registry-specs.md`).