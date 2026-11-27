I have updated the Registry Low-Level Design (`docs/intent/registry/registry-design.md`) and updated the architecture reference in `docs/high-level-design.md` to incorporate the local embedded SQLite index.

Here is the updated design document in full:

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks run air-gapped without network connectivity, requiring self-contained local lookup.

## Architecture and Interface

The registry component encapsulates all snapshot validation, index construction, and query execution. It exposes a single lookup interface to consumers:

`findBySerial(serial)` returning:
- `Found(record, snapshotDate)`
- `NotFound(snapshotDate)`

Record fields comprise:
- `serial`: Equipment serial number (string)
- `description`: Equipment description (string)
- `calibrationDate`: Last calibration date (ISO 8601 date string)
- `dueDate`: Calibration due date (ISO 8601 date string)

The certificates component communicates exclusively via this interface. All underlying SQLite storage, schemas, query mechanics, and file paths are private to the registry component.

## Local Storage and Index Structure

Registry lookups are backed by a local embedded SQLite database file stored on the kiosk filesystem.

### Schema
The SQLite database contains two tables:

1. `metadata`: Stores snapshot-level metadata.
   - `snapshot_date` (TEXT, NOT NULL): ISO 8601 date string of the snapshot.
   - `schema_version` (INTEGER, NOT NULL): Version number of the snapshot payload format.
   - `record_count` (INTEGER, NOT NULL): Total number of indexed equipment records.

2. `equipment`: Stores equipment calibration records.
   - `normalized_serial` (TEXT PRIMARY KEY): Normalized serial number used for index lookups (trimmed whitespace, uppercase ASCII).
   - `serial` (TEXT, NOT NULL): Original serial number string as provided in the snapshot.
   - `description` (TEXT, NOT NULL): Equipment description.
   - `calibration_date` (TEXT, NOT NULL): Calibration date string.
   - `due_date` (TEXT, NOT NULL): Calibration due date string.

An index on `normalized_serial` (via primary key B-tree) guarantees serial number lookups resolve within milliseconds, well beneath the kiosk goal of 250 ms for ~90,000 records.

### Database Connection and Concurrency
- Lookups open the active SQLite database in read-only mode (`PRAGMA query_only = ON`).
- Write operations occur solely during snapshot import against an isolated staging file.

## Snapshot Import and Activation

Snapshots arrive via approved USB media as signed archives containing:
- `manifest.sig`: Detached cryptographic signature.
- `metadata.json`: Contains `snapshotDate` and `schemaVersion`.
- `records.ndjson`: Newline-delimited JSON objects with equipment records.

### Validation Pipeline
Snapshot processing executes in strict sequential stages:
1. **Signature Verification**: Validate `records.ndjson` and `metadata.json` against `manifest.sig` using the kiosk's bundled public key. If verification fails, abort immediately.
2. **Schema Compatibility**: Verify `schemaVersion` against supported schema versions. If unsupported, abort immediately.
3. **Record Validation**: Stream `records.ndjson` to ensure valid JSON syntax, required fields (`serial`, `description`, `calibrationDate`, `dueDate`), and serial number uniqueness. If duplicates or malformed records are found, abort immediately.

### Staging and Atomic Activation
To guarantee zero exposure of partial data and zero disruption to active lookups:
1. The new SQLite database is constructed in a temporary staging file (e.g., `registry_staging.db`).
2. Records are bulk-inserted within a single transaction, and the primary key / index is established.
3. Once the database is fully populated and verified, the staging file is closed.
4. The staging file is atomically moved/renamed over the active database file path (e.g., `registry.db`) via filesystem atomic rename (`rename(2)` / transactional file replacement).
5. Any subsequent `findBySerial` call opens or references the new database.
6. If any step fails (signature failure, schema mismatch, duplicate serials, disk space exhaustion, or write error), the staging file is unlinked, the active SQLite database remains untouched, and a structured error is reported.

## Lookup Behavior

When `findBySerial(serial)` is invoked:
1. Normalize the query serial number:
   - Trim leading and trailing whitespace.
   - Convert ASCII lowercase characters to uppercase.
   - Retain all serial-number punctuation and non-ASCII characters without modification.
2. Query the active SQLite database:
   ```sql
   SELECT serial, description, calibration_date, due_date
   FROM equipment
   WHERE normalized_serial = :normalized_serial;
   ```
3. Retrieve the active snapshot date from the `metadata` table.
4. Return:
   - If a record is matched: `Found(record, snapshotDate)`
   - If no record matches: `NotFound(snapshotDate)`
5. If no active snapshot has ever been imported (first boot / empty kiosk), lookup returns an explicit uninitialized error state or `NotFound(snapshotDate = null)`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup storage backend | Local embedded SQLite index | On-site HTTPS directory, Managed search service | Kiosks are air-gapped with no network routes permitted during operation (HLD tenet). Embedded SQLite eliminates network dependencies, latency fluctuations, timeout failures, credential management, and service infrastructure while easily satisfying the sub-250 ms lookup target for 90,000 records. Staged local compilation isolates index lifecycle entirely within the registry component. |
| Snapshot activation strategy | Staging database file with atomic filesystem rename | In-place table replace with SQLite transaction, In-memory index reload | Staging in a separate file prevents lock contention with active read queries, eliminates any possibility of partial data exposure, and ensures that failed builds or power interruptions leave the active database completely intact. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Lookup backend selection: Embedded SQLite database built locally from signed NDJSON snapshots.
2. ✅ Snapshot isolation: Atomic database file replacement ensures active index remains available and unaffected by failed imports or in-progress rebuilds.

### Deferred
1. Initial state behavior: Handling `findBySerial` when no snapshot has ever been imported on a fresh kiosk.
2. Storage threshold: Minimum free disk space verification required before accepting a 150 MB snapshot and rebuilding the SQLite index.

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`
```

---

### Phase 2 LLD Edge-Case Probe Findings

An LLD-level probe was run to identify internal edge cases and specification gaps within this component:

1. **Concurrency and Connection Reopening**: What happens to in-flight read queries or persistent read connections when `rename(2)` swaps `registry.db`? Should readers catch stale file descriptors and reopen, or open short-lived connections per query?
2. **SQLite Auxiliary Files**: If WAL mode or rollback journaling is utilized, swapping only `registry.db` could leave mismatched `-wal` or `-shm` files. Should the staging build checkpoint and close with standard journal mode prior to swap?
3. **Collision on Normalization**: Does Stage 3 uniqueness validation check raw `serial` or `normalized_serial`? If two raw serials differ only in case or whitespace, insertion into `normalized_serial PRIMARY KEY` would fail.
4. **Snapshot Version Progression**: Does snapshot import allow downgrading or re-importing equal/older `snapshotDate`s, or must `snapshotDate` strictly advance?
5. **Fresh/Uninitialized Kiosk State**: When `findBySerial` is called prior to any snapshot import, should the signature be `NotFound(snapshotDate: null)` or an explicit `Uninitialized` error?

---

Please review the LLD design and triage these probe questions (which should be incorporated directly into the LLD now versus deferred). Once approved, we will proceed to Phase 3 (EARS specs).