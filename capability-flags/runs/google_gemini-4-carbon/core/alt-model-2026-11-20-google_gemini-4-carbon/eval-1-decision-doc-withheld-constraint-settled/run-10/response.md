I updated `docs/intent/registry/registry-design.md` to complete the Registry LLD around the local embedded SQLite index (recording the backend choice in `Decisions & Alternatives`), and removed the now-stale `"Its private lookup backend remains open."` sentence from `docs/high-level-design.md`.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number at an offline metrology kiosk and need its equipment description, calibration date, and due date, along with the date of the registry snapshot used. Updates arrive on approved USB media as signed snapshots containing a signature manifest, a schema version, a snapshot date, and newline-delimited JSON (NDJSON) equipment records (approximately 90,000 records, up to 150 MB).

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, and a snapshot import operation that validates and activates a signed snapshot from local media. Record fields (`serial`, `description`, `calibrationDate`, `dueDate`) and lookup result types are fixed. The certificates component uses only `findBySerial(serial)` and never reads registry storage directly.

Registry stores the active snapshot in a private local embedded SQLite database file on the kiosk filesystem. Snapshot validation, SQLite index construction, active-snapshot tracking, and read-only SQLite queries all belong to this node.

## Local SQLite Index

Each imported snapshot is built as an immutable SQLite database file inside Registry's private local storage directory:

- `snapshot_meta`: single-row table storing `schema_version` and `snapshot_date` so each database file is self-describing.
- `equipment`: table keyed by `normalized_serial TEXT PRIMARY KEY`, storing `serial`, `description`, `calibration_date`, and `due_date`.

Indexing `normalized_serial` as the primary-key B-tree enforces serial-number uniqueness during import and serves exact-match lookups from local disk within the 250 ms target on 4 GB RAM kiosks without holding all 90,000 records in memory.

## Snapshot Import

1. Verify the snapshot's cryptographic signature manifest using the bundled public key before trusting metadata or records.
2. Validate that the schema version is supported and the snapshot date is valid.
3. Create a fresh staging SQLite file in Registry's storage directory and stream NDJSON records into `equipment` within a single transaction, normalizing each record's serial number for `normalized_serial` so memory usage stays bounded for snapshots up to 150 MB.
4. Reject the import if signature verification fails, the schema version is unsupported, any record is malformed, or a duplicate serial number violates the primary-key constraint.
5. After the staging transaction commits and closes cleanly, atomically switch the active snapshot reference to the new SQLite file and remove the superseded database file once no in-flight lookup is reading it.

An import failure deletes the staging SQLite file, leaves the previous valid snapshot active, and returns a descriptive error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters (`a`–`z` to `A`–`Z`) before lookup. Internal whitespace and serial-number punctuation remain significant.

Capture the active SQLite database handle once per lookup and query `normalized_serial` alongside `snapshot_date` from `snapshot_meta` against that same database in read-only mode. Return `Found(record, snapshotDate)` when a matching record exists, or `NotFound(snapshotDate)` when no record matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service; unindexed NDJSON scan or full in-memory map | Kiosks operate offline with no runtime network route, eliminating network directories and managed search services. An on-disk SQLite B-tree index meets the 250 ms lookup target across 90,000 records (up to 150 MB snapshots) without holding the full dataset in 4 GB of kiosk RAM or scanning NDJSON per lookup. |
| Snapshot replacement | Build a fresh staging SQLite file per import and swap the active reference atomically | Mutate a single SQLite database in place within a transaction | Isolating import writes in a staging file prevents write contention with active kiosk lookups and guarantees a failed or interrupted import leaves the active SQLite database untouched. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`registry-specs.md`), please review the LLD above and triage which of these component-internal gaps to specify in `registry-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **Lookup before first snapshot import (cold kiosk):** What happens when `findBySerial(serial)` is called before any valid snapshot has been imported, given that both `Found` and `NotFound` require a `snapshotDate`? (e.g., kiosks ship pre-seeded with an initial snapshot, `findBySerial` adds an `Uninitialized` / error outcome, or Registry refuses startup without a valid active DB.)
2. **Older or same-date snapshots:** What happens when a validly signed snapshot has a `snapshotDate` earlier than (or equal to) the currently active snapshot? Should Registry reject downgrades (`<`), require strictly newer dates (`<=`), or accept any validly signed snapshot to allow intentional rollbacks and same-day corrections?
3. **Import contract and error shape:** What signature should the import entry point expose (e.g., `importSnapshot(path) -> ImportResult`), and should import failures return typed error categories (invalid signature, unsupported schema, malformed record, duplicate serial, stale snapshot, I/O / disk full, import busy) or an error message?
4. **USB read / verification staging:** Should Registry copy the snapshot bundle from USB to local staging before verifying and streaming into SQLite (preventing mid-import USB removal / TOCTOU issues between signature check and record streaming, at the cost of temporary disk space), or verify and stream directly from the USB path?
5. **Normalization collisions, empty serials, and returned `record.serial`:** When two NDJSON records differ only in surrounding whitespace or ASCII case (e.g., `" ab-1 "` and `"AB-1"`), primary-key normalization rejects the snapshot as a duplicate — is that intended, should empty/whitespace-only serials in NDJSON be rejected as malformed, and should `Found.record.serial` preserve the record's trimmed original casing or store the normalized serial?
6. **Crash recovery and concurrent imports:** On startup after power loss, how is the active SQLite file tracked on disk (e.g., an atomically renamed pointer manifest with startup cleanup of orphaned staging/retired `.sqlite` files), and should a second import triggered while one is running be rejected immediately as busy or serialized?
7. **Zero-record snapshots and date validation:** Is a validly signed snapshot with zero equipment records rejected as malformed or accepted, and must `snapshotDate`, `calibrationDate`, and `dueDate` be validated as strict `YYYY-MM-DD` calendar dates during import?

How would you like to triage these items, and do you approve `registry-design.md` (with any edits from above) so we can proceed to Phase 3 (updating `registry-specs.md`)?