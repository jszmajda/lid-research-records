I updated `docs/intent/registry/registry-design.md` around the local embedded SQLite index (recording the backend choice in `Decisions & Alternatives`), and updated the one stale sentence in `docs/high-level-design.md` (`Its private lookup backend remains open.` → `its local lookup index is private to this component.`) so the HLD stays coherent while keeping SQLite details inside `registry`.

### Phase 2 Output — `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number on an offline metrology kiosk and need its equipment description, calibration date, due date, and snapshot date within 250 ms. Central inventory distributes read-only signed snapshots on approved USB media containing up to 150 MB of newline-delimited JSON (NDJSON) records (~90,000 serial numbers), a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The certificates component depends only on this interface; SQLite schema, index preparation, and local storage paths remain private to the registry component.

Snapshot verification, local SQLite index construction, atomic snapshot activation, and serial-number lookup all belong to this node.

## Storage Layout and Schema

Each validated snapshot is materialized as a standalone SQLite database file inside a registry-owned local directory on the kiosk:

- `snapshot_meta`: single-row table (`id INTEGER PRIMARY KEY CHECK (id = 1)`) storing `snapshot_date` and `schema_version`.
- `equipment_records`: table keyed by `normalized_serial TEXT PRIMARY KEY` (`WITHOUT ROWID`), storing `serial_number`, `description`, `calibration_date`, and `due_date`.

Keying `equipment_records` on `normalized_serial` enforces serial-number uniqueness during import and provides single-seek B-tree lookups across 90,000 records without holding the snapshot resident in memory on a 4 GB kiosk.

## Snapshot Import

1. **Signature and version check**: Verify the snapshot signature manifest against the snapshot payload using the bundled public key and reject unsupported `schema_version` values before indexing records.
2. **Streaming staged build**: Create a new staged SQLite file in the same local directory as the active index and stream NDJSON records into `equipment_records` within a single write transaction so memory usage stays bounded for 150 MB snapshots. Normalize each record's serial number before insertion; duplicate serial numbers fail the primary-key constraint and abort the import.
3. **Finalization and atomic activation**: Write `snapshot_meta`, commit in rollback-journal mode so the database is self-contained in one file, sync to disk, and atomically cut over the active database path only after validation succeeds for the entire snapshot.
4. **Failure isolation**: If signature verification, schema validation, record parsing, uniqueness validation, or SQLite writes fail at any stage, remove the staged file, retain the existing active database unchanged, and return a descriptive import error.

## Lookup Behavior

Normalize the requested `serial` by trimming surrounding whitespace and uppercasing ASCII letters (`a`–`z` to `A`–`Z`). Punctuation remains significant.

Open the active SQLite database in read-only mode and execute lookup within a single read transaction that reads `snapshot_meta.snapshot_date` and queries `equipment_records` by `normalized_serial`. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt per kiosk on snapshot import | On-site HTTPS directory; managed search service; raw NDJSON scan or in-memory map | Offline kiosk constraints prohibit runtime network dependencies (HTTPS directory, managed search). Locally, a B-tree-indexed SQLite file meets the 250 ms lookup target across 90,000 records within 4 GB RAM without resident memory overhead or linear scans, keeping per-snapshot rebuild encapsulated inside the registry component. |
| Snapshot activation | Build into a staged SQLite file and cut over atomically after validation | Replace rows in place inside the active SQLite file | Staging a separate file prevents partially imported records from becoming visible, avoids write locks against active lookups, and preserves the prior valid database intact on any import failure. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`registry-specs.md`), please review the LLD above and triage which of these component-internal gaps to specify in `registry-design.md` now versus record as deferred under `Open Questions & Future Decisions`:

1. **Unprovisioned kiosk or unreadable SQLite file during lookup**: Both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require an active `snapshotDate`. What happens when `findBySerial` runs before any snapshot has ever been imported on a new kiosk, or if opening/reading the active SQLite file fails (missing file, I/O error, corruption)?
2. **Import interface, snapshot bundle layout, and error contract**: What callable signature and USB snapshot layout (e.g., directory vs. archive containing manifest + NDJSON) should `registry` expose for import, and should import failures return typed error categories (invalid signature, unsupported `schema_version`, malformed record, duplicate serial, storage failure) or a message string?
3. **Stale/older signed snapshot replay**: When a validly signed USB snapshot has a `snapshot_date` older than (or equal to) the currently active snapshot, should import reject it to prevent silent rollback, require an explicit override, or replace unconditionally?
4. **Manifest binding and USB removal mid-import**: Does the signature manifest cover `snapshot_date` and `schema_version` alongside the NDJSON payload, and should the snapshot be copied/hashed locally in one pass so removable USB media cannot change or disconnect between signature check and SQLite indexing?
5. **Cutover mechanism, concurrent imports, and crash leftovers**: Should atomic activation use POSIX same-directory `rename` onto a fixed SQLite filename (with parent-directory `fsync`) or pointer/versioned-file indirection, how should a second import request behave while one is in progress, and should startup/import sweep leftover staged files from a prior power loss?
6. **Empty snapshots and record field validation**: Should import reject a zero-record snapshot, snapshots exceeding 150 MB, blank/whitespace-only serial numbers, missing descriptions, or invalid ISO calendar dates (`snapshot_date`, `calibration_date`, `due_date`)? Also, should `record.serial_number` return the raw NDJSON string or the trimmed/uppercased form?
7. **Whitespace definition and blank lookup input**: Should normalization trim ASCII whitespace only or Unicode whitespace (such as `U+00A0` from spreadsheet exports), and should `findBySerial("")` / whitespace-only input return `NotFound(snapshotDate)` or reject blank input?

Let me know any edits to the LLD and how you want to triage items 1–7, or confirm if you are ready to proceed to Phase 3 (EARS updates).