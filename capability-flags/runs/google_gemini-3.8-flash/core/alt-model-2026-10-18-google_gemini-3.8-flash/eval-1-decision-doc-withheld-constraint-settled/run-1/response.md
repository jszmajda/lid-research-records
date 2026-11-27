## Phase 2: Registry Low-Level Design (Completed)

The registry LLD (`docs/intent/registry/registry-design.md`) and high-level design reference (`docs/high-level-design.md`) have been updated to reflect the local embedded SQLite index choice.

### Updated LLD: `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians at metrology kiosks enter equipment serial numbers to verify calibration status and retrieve equipment metadata before preparing inspection certificates. The registry operates entirely offline inside an isolated production environment, sourcing data exclusively from signed snapshots delivered via approved USB media.

Guiding principles:
- **Offline autonomy**: No network dependencies, background daemons, or remote services at runtime.
- **Fail-safe activation**: Snapshot ingestion must be all-or-nothing; failures must never corrupt or displace the currently active snapshot.
- **Predictable low latency**: Lookups must execute within 250 ms across approximately 90,000 records on kiosk hardware with 4 GB of RAM.

## Architecture

The registry component encapsulates snapshot ingestion, validation, embedded SQLite database management, and query execution. It exposes a single query interface consumed by the certificates component:

```
findBySerial(serial: string) -> Found(record, snapshotDate) | NotFound(snapshotDate)
```

Record fields:
- `serial_number`: Normalized string identifier
- `description`: Text description of equipment
- `calibration_date`: ISO 8601 date string
- `due_date`: ISO 8601 date string

The certificates component depends only on this interface and remains agnostic to SQLite storage, schema, and query mechanics.

## Snapshot Import and Index Build

Snapshots arrive as packages containing newline-delimited JSON (NDJSON) records, a schema version identifier, a snapshot date, and a cryptographic signature manifest.

### Import Pipeline

1. **Signature Verification**: Validate the snapshot manifest signature against the kiosk's bundled public key. Reject tampered or unsigned packages before parsing data.
2. **Schema Validation**: Verify that the snapshot schema version is supported by the current kiosk software release. Reject unsupported versions.
3. **Staging Database Build**:
   - Create a fresh, temporary staging SQLite database file (`registry_staging.db`).
   - Insert snapshot metadata (schema version, snapshot date, import timestamp).
   - Parse and stream NDJSON records into the staging database within a single transaction.
   - Enforce uniqueness on normalized serial numbers. If duplicates or malformed rows are detected, abort the transaction and reject the import.
   - Build a B-tree index on the normalized serial number column.
4. **Atomic Activation**:
   - Close active staging connections and perform an atomic filesystem rename/replace swapping `registry_staging.db` into the active database path (`registry_active.db`).
   - Reopen the read-only connection to the new active database.
5. **Failure Recovery**:
   - If any validation check fails or power is interrupted during steps 1–3, the staging database is removed.
   - The preexisting `registry_active.db` remains untouched and continues serving lookups without interruption. An import error report is emitted.

## Storage and Schema

The registry uses an embedded SQLite database configured for local read-only concurrency.

### Database Settings
- Mode: `PRAGMA query_only = ON` for all lookup connections.
- Journal Mode: `WAL` (Write-Ahead Logging) or standard rollback journal to ensure non-blocking reads during background import staging.
- Synchronous: `PRAGMA synchronous = NORMAL`.

### Schema Definition
```sql
CREATE TABLE metadata (
    schema_version INTEGER NOT NULL,
    snapshot_date TEXT NOT NULL,
    imported_at TEXT NOT NULL
);

CREATE TABLE equipment (
    serial_number TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    calibration_date TEXT NOT NULL,
    due_date TEXT NOT NULL
);

CREATE INDEX idx_equipment_serial ON equipment (serial_number);
```

With `serial_number` as the primary key B-tree index, exact lookups across 90,000 records require minimal page reads, comfortably satisfying the 250 ms latency threshold on 4 GB RAM kiosks.

## Lookup Behavior

1. **Input Normalization**:
   - Trim leading and trailing whitespace.
   - Convert ASCII letters to uppercase.
   - Preserve all internal punctuation, hyphens, and symbols (e.g., `" cal-100-a "` normalizes to `"CAL-100-A"`).
2. **Query Execution**:
   - Query `SELECT description, calibration_date, due_date FROM equipment WHERE serial_number = ?` using the normalized string.
   - Query `SELECT snapshot_date FROM metadata LIMIT 1`.
3. **Response Construction**:
   - If a matching row is found, return `Found(record, snapshotDate)`.
   - If no row matches, return `NotFound(snapshotDate)`.
   - The active `snapshotDate` is returned in both cases so downstream callers (including certificate generators) can report snapshot provenance.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, managed search service | Adheres to the offline kiosk tenet requiring zero runtime network dependencies; avoids service management and network timeout handling; encapsulates all data handling in the registry component; guarantees predictable sub-250ms lookups for 90,000 records on 4 GB RAM hardware. |
| Import atomicity | Staging SQLite database file with atomic filesystem rename | In-place transaction with rollback, in-memory rebuild | Preserves the active database intact if kiosk power is interrupted or validation fails during index build; prevents lookups from blocking during import or exposing partial data. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Lookup backend selected as local embedded SQLite index.
2. ✅ Atomic snapshot replacement using staging database and atomic file replacement.
3. ✅ Lookup input normalization strategy (whitespace trimming and ASCII uppercase).

### Deferred
1. Concrete directory paths for active/staging database files and public keys across kiosk operating systems.
2. Retention policy for previous snapshot database files (e.g., keeping one prior backup file for quick rollback).

## References

- `docs/high-level-design.md`
- `docs/intent/certificates/certificates-design.md`
- `docs/intent/registry/registry-specs.md`
```

---

### LLD-Level Edge-Case Probe Findings

An independent inspection of internal gaps within this LLD surfaced the following considerations:

1. **Missing State Transitions**:
   - Cold start: What does `findBySerial` return when invoked on a newly commissioned kiosk before any snapshot has been imported (no `registry_active.db` exists)?
   - Initial failure: If the first import on a fresh kiosk fails, does it report a distinct uninitialized state?
   - In-progress collisions: What happens if an import is triggered while another import pipeline is actively staging or indexing?
   - Snapshot ordering: What happens if an imported snapshot package carries an older `snapshot_date` or lower schema version than the active database?

2. **Unstated Invariants**:
   - Serial normalization collisions: If raw NDJSON contains entries that differ only by case (e.g., `"cal-100"` and `"CAL-100"`), does uniqueness validation catch the normalized collision prior to index build?
   - Date validity: Does the import pipeline validate ISO 8601 calendar date formats and verify that `calibration_date <= due_date`?
   - Non-ASCII/Control characters: How are control characters or unicode characters in input serial numbers handled?

3. **Error Shapes & Connection Coordination**:
   - Query errors: If `registry_active.db` suffers disk corruption or I/O failure, does `findBySerial` have an explicit error representation or throw?
   - Lock coordination: Under WAL mode, does an atomic rename require draining active reader file descriptors, or will readers seamlessly pivot to the replaced file inode?

---

### Phase 2 Review

Please review the LLD design and indicate:
1. Which probe items (if any) you would like addressed directly in `registry-design.md` vs. deferred as open questions?
2. Approval to proceed to **Phase 3: EARS spec draft or update**.