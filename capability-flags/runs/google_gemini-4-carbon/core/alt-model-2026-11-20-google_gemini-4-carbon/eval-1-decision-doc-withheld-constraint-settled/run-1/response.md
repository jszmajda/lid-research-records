Updated `docs/intent/registry/registry-design.md` around the local embedded SQLite index (recording the backend choice in `Decisions & Alternatives`) and cleared the `"Its private lookup backend remains open."` placeholder in `docs/high-level-design.md` so both docs stay coherent while keeping storage details private to `registry`.

### Phase 2 Output — `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number on an offline kiosk and need its calibration date, due date, and equipment description within 250 ms across approximately 90,000 records. Updates arrive on approved USB media as signed snapshots up to 150 MB containing newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, where `record` carries the serial number, equipment description, calibration date, and due date. The certificate component uses only this lookup interface. Expose a separate snapshot-import operation for applying signed USB snapshots on the kiosk.

Snapshot validation, local index construction, storage paths, and query execution are private to this node. Each kiosk maintains a local embedded SQLite index built from the active snapshot and queried in-process with no background service or network access.

## Storage and Schema

Each validated snapshot is materialized as a standalone, immutable SQLite database file on local kiosk storage containing two tables:

- `snapshot_meta`: single-row table storing `schema_version` and `snapshot_date`, binding the snapshot date to the exact record set in the same file.
- `equipment_records`: keyed by `normalized_serial` (`TEXT PRIMARY KEY`), storing the record's `serial`, `description`, `calibration_date`, and `due_date`.

Keeping `snapshot_meta` and `equipment_records` in one SQLite file ensures every `Found` and `NotFound` result reports the `snapshotDate` of the exact index generation queried.

## Snapshot Import

Import builds and validates a candidate index without mutating the active database:

1. **Verify package**: Verify the signature manifest against the bundled public key before ingesting records, and reject unsupported `schema_version` values.
2. **Stream into staged SQLite**: Create a new SQLite file in a staging path on the same local filesystem as the active index. Stream NDJSON records sequentially inside a write transaction so memory usage stays bounded well within the 4 GB kiosk RAM budget on 150 MB snapshots. Normalize each record's serial number (trim surrounding whitespace, uppercase ASCII letters, preserve punctuation) before inserting into `equipment_records`; reject the snapshot if any record is malformed, missing required fields, or collides on `normalized_serial`. Write `schema_version` and `snapshot_date` to `snapshot_meta`.
3. **Activate atomically**: Flush and sync the staged SQLite file to disk, then atomically repoint the active index on the local filesystem so lookups observe either the complete replacement snapshot or the complete prior snapshot, never a partial import.
4. **Retain active snapshot on failure**: On signature failure, unsupported schema version, malformed JSON or fields, duplicate serial number, or local storage error, remove any staged file, leave the active SQLite database untouched, and return a descriptive import error.

## Lookup Behavior

Normalize the requested `serial` using the same rule applied during import: trim leading and trailing whitespace and uppercase ASCII letters (`a`–`z` to `A`–`Z`) while keeping internal characters and punctuation significant.

Query the active SQLite database in read-only mode with an indexed point lookup on `normalized_serial` alongside `snapshot_date` from `snapshot_meta`. Return `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no row matches. A single local B-tree lookup over 90,000 rows keeps latency well within the 250 ms target without holding the full registry in memory.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on each kiosk per snapshot | On-site HTTPS directory; managed search service; direct NDJSON scan or full in-memory map | Offline kiosk operation with no runtime network route rules out networked services. A local B-tree index meets the 250 ms / 90,000-record goal within 4 GB RAM without per-lookup 150 MB scans or resident memory overhead, keeping all index concerns inside the registry component. |
| Index replacement | Build a fresh staged SQLite file per snapshot and swap atomically | Update a single SQLite database in place during import | Isolates read-only lookups from import writes and guarantees failed imports leave the active snapshot intact without journal rollback risk. |
```

---

### LLD Edge-Case Probe (for Triage)

Before moving to Phase 3 (`registry-specs.md`), please let me know which of these internal gaps to settle in the LLD now versus defer under `Open Questions & Future Decisions`:

1. **Uninitialized or unreadable active index**: What happens when `findBySerial(serial)` is called before any snapshot has ever been imported on a kiosk (or if the active SQLite file is missing/corrupt), given both `Found` and `NotFound` carry `snapshotDate`? (e.g., kiosks always ship pre-seeded + surface an explicit storage/uninitialized error, or add a distinct result variant.)
2. **Stale or same-date snapshots**: What happens when a validly signed snapshot has a `snapshot_date` older than (or equal to) the currently active snapshot? (Reject downgrades, allow any signed snapshot for operator rollback, or require an explicit override?)
3. **Import contract and error shape**: What signature and return/error types should the snapshot-import operation expose (e.g., structured error variants for bad signature, unsupported schema, malformed line/duplicate serial, storage error vs. a message string)?
4. **Cutover mechanics, live readers, and cleanup**: How should active-index repointing and SQLite connection lifecycle coordinate during a swap (e.g., atomic pointer/rename + generation check or per-lookup read-only open), and when are superseded SQLite files and interrupted staging leftovers cleaned up?
5. **USB read integrity during streaming**: Should import copy the snapshot from removable USB media to local staging before verifying and streaming (avoiding USB disconnect/TOCTOU mid-import at the cost of temporary disk space), or stream directly from USB while verifying digest before activation?
6. **Record & serial edge cases**: Should `record.serial` in `Found` return the normalized serial or the raw record value; are empty/whitespace-only serials and zero-record snapshots rejected on import; and should `calibration_date`, `due_date`, and `snapshot_date` be validated as strict `YYYY-MM-DD` dates?
7. **Signing-key rotation**: Should verification support a keyring keyed by `key_id` so signing keys can rotate across offline kiosks without a simultaneous software update, or pin a single bundled public key?

How would you like to triage these items, and do you approve the LLD (with your adjustments) to proceed to Phase 3 (EARS specs)?