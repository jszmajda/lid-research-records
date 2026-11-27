I have completed the registry low-level design (`docs/intent/registry/registry-design.md`) incorporating the local embedded SQLite index, and aligned `docs/high-level-design.md`.

Per Phase 2 of `linked-intent-dev`, an LLD-level edge-case probe was executed against `registry-design.md` to surface internal gaps before proceeding to EARS specification (Phase 3).

---

### Revised Registry Design (`docs/intent/registry/registry-design.md`)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and require its calibration date, calibration due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Because kiosks operate without network connectivity, the registry maintains a local embedded SQLite database derived from imported snapshots, providing deterministic, sub-millisecond lookups while keeping index preparation and storage completely internal to the registry component.

## Architecture

The registry exposes a query interface consumed by the certificates component:

```
findBySerial(serial: string) -> Found(record, snapshotDate) | NotFound(snapshotDate)
```

The returned `record` contains:
- `serial`: string (original raw serial number)
- `description`: string
- `calibrationDate`: string (ISO 8601 date)
- `dueDate`: string (ISO 8601 date)

The certificates component depends only on this interface and does not access the underlying SQLite storage or import mechanisms.

Internally, the registry consists of three subsystems:
1. **Import Engine**: Ingests snapshot archives from USB media, verifies digital signatures, validates schema and record integrity, and populates a staging SQLite database.
2. **Storage Engine**: Manages local SQLite database files, atomic activation of new snapshot databases, and read-only connection pooling.
3. **Lookup Engine**: Normalizes serial number inputs and executes indexed point lookups against the active SQLite database.

## Storage and Index Schema

The registry uses an embedded SQLite database (`active.db` pointing to the current verified snapshot). Lookups run against this file in read-only mode (`PRAGMA query_only = ON;`).

### Database Schema

```sql
CREATE TABLE metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

CREATE TABLE equipment (
    normalized_serial TEXT PRIMARY KEY,
    raw_serial TEXT NOT NULL,
    description TEXT NOT NULL,
    calibration_date TEXT NOT NULL,
    due_date TEXT NOT NULL
);
```

- `metadata` stores operational snapshot headers: `snapshot_date` and `schema_version`.
- `equipment.normalized_serial` serves as the primary key and creates an automatic unique B-tree index, guaranteeing O(log N) point lookup performance across ~90,000 records.
- Database file size for 90,000 records is approximately 15–25 MB, well within kiosk memory (4 GB RAM) and disk budgets.

## Snapshot Import and Activation

Snapshot import processes an external file without interrupting active kiosk lookups or exposing unverified or partial data:

1. **Signature Verification**: Verifies the snapshot archive's manifest signature using a public key bundled into the kiosk software. If signature verification fails, import terminates immediately.
2. **Schema & Header Check**: Reads the snapshot metadata header. Unsupported schema versions are rejected.
3. **Staging Database Creation**: A fresh SQLite database file is created in a temporary staging location (`staging-<timestamp>.db`).
4. **Record Parsing & Validation**: Records are parsed from newline-delimited JSON and inserted in batches within a single transaction. Each record's serial number is normalized. If a duplicate normalized serial number is encountered, the import is rejected.
5. **Validation & Finalization**: The transaction commits, the `metadata` table is populated with the snapshot date and schema version, and an integrity check (`PRAGMA quick_check;`) is performed.
6. **Atomic Activation**: The newly populated database file is promoted to the active database (via atomic file rename or atomic pointer swap). Ongoing or future `findBySerial` calls immediately read from the new snapshot.
7. **Failure Rollback**: Any error during steps 1–5 (signature invalid, schema unsupported, corrupt JSON, duplicate serials, disk full) aborts the import, removes the staging file, leaves the existing active database intact, and returns a descriptive error.

## Lookup Behavior

`findBySerial(serial)` executes as follows:

1. **Input Normalization**:
   - Strip leading and trailing whitespace.
   - Convert ASCII lowercase letters to uppercase.
   - Retain all digits, punctuation, and non-ASCII characters without modification.
2. **Database Query**:
   - Query `equipment` for `normalized_serial = ?`.
   - Retrieve `snapshot_date` from `metadata`.
3. **Result Construction**:
   - If a row is found: return `Found(record, snapshotDate)` with the stored `raw_serial`, `description`, `calibration_date`, and `due_date`.
   - If no row is found: return `NotFound(snapshotDate)`.
   - If no snapshot has been imported yet on a fresh kiosk: return an uninitialized error state or `NotFound("")`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, Managed search service | Satisfies the offline kiosk mandate (zero runtime network dependency). Provides deterministic sub-millisecond lookups for 90,000 records within the 250 ms budget. Eliminates network timeouts, external service credentials, and recurring infrastructure costs. Rebuilding the local index during snapshot import is entirely self-contained within the registry. |
| Snapshot activation strategy | Staging database file with atomic rotation | In-place table updates in live database | Ensures active lookups never observe partial or unverified records during imports. Rollback on import failure is instantaneous and leaves the prior database completely untouched. |
| Lookup indexing key | Pre-normalized serial primary key | Case-insensitive collation (`COLLATE NOCASE`) or runtime `UPPER()` | Pre-normalizing during snapshot ingestion ensures fast index seeks on exact binary matches and explicitly handles whitespace trimming which `COLLATE NOCASE` does not address. |

## Open Questions & Future Decisions

### Resolved
1. Local SQLite index selected as the lookup backend.
2. Snapshot replacement uses staging database and atomic activation.
3. Serialization format in SQLite separates normalized key from display `raw_serial`.

### Deferred
1. Disk retention policy for superseded snapshot database files (e.g. keep previous snapshot for immediate rollback vs. immediate deletion to preserve kiosk disk space).
2. Explicit behavior/UI presentation when a kiosk starts fresh before any snapshot has ever been imported.

## References

- `docs/high-level-design.md`
- `docs/intent/certificates/certificates-design.md`
- `docs/intent/registry/registry-specs.md`
```

---

### Phase 2 Edge-Case Probe (Gaps in this LLD)

1. **Uninitialized kiosk state**: What should `findBySerial` return on a brand-new kiosk before any snapshot has been imported? Should the return type explicitly include `Uninitialized` / `NoActiveSnapshot`, or return `NotFound("")`?
2. **Runtime database corruption / disk errors**: If `active.db` encounters an unreadable block or corruption during kiosk operation, how should `findBySerial` surface operational errors to the caller?
3. **Empty/whitespace input**: Should `findBySerial` immediately return `NotFound(snapshotDate)` or an input validation error when given an empty or whitespace-only serial number?
4. **Connection invalidation on swap**: When a new database is activated via file rename or pointer swap, how should active read connections drain or rebind to avoid holding locks or reading stale inodes?
5. **Lookup query atomicity**: If activation occurs between querying `equipment` and querying `metadata`, how does the lookup engine prevent combining a record from snapshot $N$ with the snapshot date of snapshot $N+1$?
6. **Concurrent imports**: If a technician triggers an import while an import is in progress, how should the registry coordinate them (e.g. lockfile/mutex rejecting the second request)?
7. **Crash / power loss recovery**: If power is cut mid-import, what startup routine cleans orphaned `staging-*.db` files to prevent disk exhaustion?
8. **Chronological snapshot ordering**: What happens if an imported snapshot has a `snapshot_date` older than the currently active snapshot—should downgrades be rejected, warned, or allowed?

---

Please review the LLD and triage which edge cases above should be settled directly in the LLD versus deferred to implementation before we move to Phase 3 (EARS specs).