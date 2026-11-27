I have updated `docs/intent/registry/registry-design.md` around the local embedded SQLite index, recorded the backend selection in its `Decisions & Alternatives` table, and updated line 13 of `docs/high-level-design.md` so it no longer states that the private lookup backend remains open.

### Updated LLD (`docs/intent/registry/registry-design.md`)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number on an offline metrology kiosk and need its calibration date, due date, and equipment description within 250 ms on hardware with 4 GB of RAM. Inventory data arrives from approved USB media as a signed snapshot (~90,000 records, up to 150 MB) containing newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Registry data is read-only on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, where `record` carries the serial number, equipment description, calibration date, and due date. The `certificates` component accesses registry data exclusively through this interface.

Snapshot validation, index construction, and lookup live entirely inside this component, backed by a private local embedded SQLite database file. Each activated snapshot is stored as a self-contained, immutable SQLite file holding both the indexed equipment records and the snapshot metadata, ensuring record lookups and `snapshotDate` reads always come from the same snapshot generation. Lookups execute in-process against local kiosk files with no background service or network access.

## Storage Schema

Serial numbers are normalized by trimming leading and trailing ASCII whitespace and converting ASCII lowercase letters (`a`–`z`) to uppercase (`A`–`Z`), while keeping internal characters and serial-number punctuation intact. Both snapshot import and lookup apply this same normalization rule.

Each snapshot SQLite database contains two tables:

| Table | Columns | Notes |
|---|---|---|
| `snapshot_meta` | `id INTEGER PRIMARY KEY CHECK (id = 1)`, `schema_version TEXT NOT NULL`, `snapshot_date TEXT NOT NULL` | Enforces a single metadata row storing the manifest's `schemaVersion` and `snapshotDate` for on-disk compatibility checks and lookup responses. |
| `equipment_records` | `normalized_serial TEXT PRIMARY KEY`, `serial_number TEXT NOT NULL`, `equipment_description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, `due_date TEXT NOT NULL` | Primary-key B-tree index on `normalized_serial` supports direct point lookups and enforces serial uniqueness. |

## Snapshot Import

Import builds and validates a complete replacement database before exposing any of its records:

1. Verify the signature manifest against the bundled public key before parsing record payloads.
2. Validate the manifest's `schemaVersion` against supported versions and reject unsupported schemas.
3. Remove any leftover staging files from prior interrupted imports and create a fresh staging SQLite file in the registry's local storage directory on the same filesystem as the active database.
4. Stream newline-delimited JSON records line by line inside a single write transaction so memory usage stays bounded within the 4 GB kiosk envelope for snapshots up to 150 MB.
5. Normalize each record's serial number, enforce uniqueness across the snapshot, insert validated rows into `equipment_records`, and write `schema_version` and `snapshot_date` into `snapshot_meta`.
6. Commit the transaction, flush (`fsync`) the staging file, and close the write connection.
7. Activate the snapshot by atomically renaming the staging file over the active database path, syncing the parent directory, swapping the active read-only SQLite handle to the new file, and closing the retired handle once any in-flight read completes.

If signature verification, schema validation, record parsing, field or uniqueness validation, or SQLite file preparation fails at any step, the registry aborts the import, removes the staging file, leaves the previously active SQLite database serving lookups, and returns a descriptive import error.

## Lookup Behavior

Normalize the requested `serial` using the serial-normalization rule above. Query the active read-only SQLite connection for `normalized_serial` in `equipment_records` alongside `snapshot_date` from `snapshot_meta`. Return `Found(record, snapshotDate)` when a matching row exists, or `NotFound(snapshotDate)` when no matching row exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service; unindexed scan of raw NDJSON snapshot | Offline kiosk constraints prohibit runtime network access, eliminating an HTTPS directory or managed search service. An embedded SQLite B-tree index runs in-process with no service to manage, keeps RAM usage bounded on 4 GB kiosks, and meets the 250 ms lookup target across 90,000 records while keeping storage details private to the registry component. |
| Snapshot update strategy | Build a fresh read-only SQLite file in staging and activate via atomic file rename | Mutate rows in place inside a single long-lived SQLite database | Snapshots arrive as complete signed inventories rather than incremental updates. Staging a fresh database file and atomically renaming it prevents partial exposure during import, avoids write contention with concurrent lookups, and leaves the prior valid database intact if import fails. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`registry-specs.md`), please review the LLD above and let me know which of these internal gaps to resolve in `registry-design.md` now vs. defer under `Open Questions & Future Decisions`:

1. **Lookup before any snapshot is imported (cold start):** What happens when `findBySerial(serial)` is called on a freshly deployed kiosk before its first USB snapshot import (since both `Found` and `NotFound` require a `snapshotDate`)—is an initial snapshot guaranteed at provisioning time, or does `findBySerial` need an uninitialized/error state?
2. **Older or same-date snapshot imports:** What happens when a validly signed snapshot has a `snapshotDate` older than or equal to the currently active snapshot—accept it (to allow intentional rollbacks) or reject downgrades?
3. **Import entrypoint & error contract:** What public interface and structured error shape should snapshot import expose (e.g., `importSnapshot(path)` returning the activated `snapshotDate` and record count vs. typed error cases for bad signature, unsupported schema, invalid/duplicate record, and I/O or disk-full failure)?
4. **Snapshot bundle & signature coverage:** What is the concrete layout of a signed snapshot on USB (directory vs. archive, signature algorithm, and confirming the signature binds `schemaVersion` and `snapshotDate` alongside the NDJSON stream so verification can stream within the 4 GB RAM budget)?
5. **Normalization collisions & returned `serial` format:** When two records in a snapshot differ only by surrounding whitespace or ASCII letter case (e.g., `"ab-1"` and `"AB-1 "`), `normalized_serial` treats them as duplicates and rejects the snapshot—is that intended, and for valid lookups should `Found.record` carry the raw `serial` string from the snapshot or the normalized form?
6. **Concurrent imports:** What happens if a second snapshot import is triggered while an import is already running—reject immediately as busy or serialize behind a lock?
7. **Boundary inputs & corrupt on-disk DB:** What happens on empty/whitespace-only lookup input (`NotFound(snapshotDate)`?), a valid snapshot with 0 records or >150 MB size, or an unreadable/schema-mismatched active SQLite file on startup or lookup?

How would you like to triage these items, and do you approve the `registry-design.md` update once adjusted?