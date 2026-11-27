I have updated `docs/intent/registry/registry-design.md` with the local embedded SQLite index design (recording the backend choice in `Decisions & Alternatives`), and updated the one stale line in `docs/high-level-design.md` (`"Its private lookup backend remains open."` → `"Owns snapshot validation, local index preparation, and lookup; its lookup storage stays private to this component."`) so the HLD stays coherent while keeping storage details private to Registry.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number at a kiosk and need its equipment description, calibration date, and calibration due date, paired with the date of the registry snapshot used. Registry data arrives on approved USB media as a signed snapshot package containing a signature manifest, schema version, snapshot date, and approximately 90,000 newline-delimited JSON (NDJSON) equipment records (up to 150 MB). Lookups must complete locally within 250 ms on kiosks with 4 GB of RAM and no runtime network access.

## Architecture and Interface

Registry owns snapshot verification, local SQLite index construction, and serial-number lookup. SQLite file paths, table layout, and query execution stay internal to this component; the certificates component interacts only through the lookup interface.

- `findBySerial(serial)` returns either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- `record` provides `serial`, `description`, `calibrationDate`, and `dueDate`.
- `importSnapshot(packagePath)` validates a signed snapshot package from USB media, builds a replacement SQLite index, and activates it atomically, or returns a structured validation/import error while leaving the active snapshot unchanged.

## Local SQLite Index Layout

Each imported snapshot is stored as a standalone, read-only SQLite database file on local kiosk storage:

- `snapshot_meta`: single-row table storing `schema_version` and `snapshot_date`.
- `equipment`: one row per record with `serial_key` (`TEXT PRIMARY KEY`, normalized lookup key), `serial` (trimmed display serial string), `description`, `calibration_date`, and `due_date`.

Because `serial_key` is the primary key, SQLite enforces serial uniqueness during index construction and serves point lookups via B-tree traversal without loading the full 90,000-row dataset into memory.

## Snapshot Import and Activation

Snapshot import builds into a staging file in the same local directory as the active index so validation and index construction never mutate or lock the active database:

1. **Manifest and signature check**: Verify the package signature manifest over the metadata and NDJSON payload against the bundled public key. Check that the declared `schema_version` is supported and `snapshot_date` is well-formed.
2. **Streaming index build**: Stream the NDJSON payload line by line so memory usage stays bounded within the 4 GB kiosk budget regardless of the 150 MB package size. Insert rows into a fresh staged SQLite file (using rollback-journal mode so the committed database is a single self-contained file without WAL sidecars) inside a single write transaction, computing `serial_key` with the same normalization rules used at lookup time. Any malformed record or duplicate `serial_key` aborts the transaction.
3. **Durability and activation**: Commit the transaction, flush and close the writer connection, open a verified read-only connection against the staged file, and atomically update the active-snapshot pointer on the same filesystem before switching the in-process reader reference. Superseded database files are removed after in-flight lookups against them finish.
4. **Failure handling**: If signature verification, schema validation, record parsing, uniqueness checks, disk writes, or reader verification fail prior to pointer swap, delete the staged file, retain the existing active SQLite database, and report the specific failure reason.

## Lookup Behavior

`findBySerial(serial)` normalizes the input string by trimming leading and trailing whitespace and converting ASCII lowercase letters (`a`–`z`) to uppercase (`A`–`Z`). Internal whitespace and punctuation remain significant.

Lookups execute against a read-only SQLite connection. Within a single read transaction, Registry reads `snapshot_date` from `snapshot_meta` and queries `equipment` by `serial_key = ?`, returning `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt per snapshot | On-site HTTPS directory; managed search service; direct scan of raw NDJSON | Kiosks forbid runtime network access (eliminating networked directory and managed search options), and a local SQLite primary-key index meets the 250 ms / 4 GB RAM budget on 90,000 records without running a separate local service or scanning up to 150 MB per lookup; trades slower USB import time for predictable local queries. |
| Snapshot replacement | Build a new staged SQLite file per snapshot and swap atomically | Update the active SQLite database in place inside a transaction | Isolates active read-only lookups from import write locks and ensures failed imports or interrupted writes cannot corrupt or partially expose the active snapshot. |

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`registry-specs.md`), please review the LLD above and triage which of these component-internal edge cases to resolve in `registry-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **Lookup before any snapshot is imported**: Both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require a `snapshotDate`. What happens when `findBySerial` is called on a newly provisioned kiosk before the first snapshot import — does kiosk provisioning guarantee a pre-seeded snapshot, does Registry refuse to start without one, or is there an uninitialized/error result?
2. **Older or equal `snapshot_date` on import (rollback policy)**: What happens when a validly signed USB snapshot has a `snapshot_date` older than or equal to the active snapshot — reject it to prevent accidental downgrade/replay, or accept it so central inventory can intentionally roll back a bad snapshot?
3. **Case/whitespace-equivalent serials in a snapshot**: With `serial_key` normalized on insert, two records like `"ab-100"` and `"AB-100 "` collide on `serial_key` and reject the snapshot as a duplicate. Is normalized uniqueness intended, and should `record.serial` preserve the trimmed original casing from the snapshot or return the normalized uppercase form?
4. **Snapshot package shape and USB read pass**: What is the concrete on-disk shape at `packagePath` (directory vs. single archive), and if USB media is unplugged mid-import or between manifest verification and NDJSON ingestion, should Registry stream-hash and build the staged SQLite file in a single pass (verifying the signature digest before activation) or copy/verify before building?
5. **Concurrent imports and orphaned staging files**: What happens if `importSnapshot` is called while another import is already running (reject immediately vs. serialize), and should Registry sweep leftover staging files on startup after an unclean power-off?
6. **Record and query validation boundaries**:
   - In NDJSON records: what date format is required for `snapshot_date`, `calibration_date`, and `due_date` (e.g., ISO `YYYY-MM-DD`), are blank/empty fields or zero-record snapshots rejected, and are unknown extra JSON fields ignored or rejected?
   - In `findBySerial(serial)`: does an empty or whitespace-only query simply return `NotFound(snapshotDate)`?
7. **Corrupt or missing active SQLite file**: What happens if local storage corruption makes the active SQLite file unreadable at startup or during `findBySerial`, given `findBySerial`'s two-variant return type?
8. **Signing key rotation**: Does the bundled public key support a single static key only, or a small keyring keyed by a key ID in the manifest?

Please share any changes to the LLD and how you want items 1–8 triaged; once you approve Phase 2, I will proceed to Phase 3 (`registry-specs.md`).