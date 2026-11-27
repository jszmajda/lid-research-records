Here is the completed Registry Low-Level Design (`docs/intent/registry/registry-design.md`), incorporating the local embedded SQLite index choice, followed by the LLD-level edge-case probe findings.

---

### `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks run in an isolated production environment without runtime network access; all lookup data must reside locally on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the internal storage engine. The certificates node interacts exclusively with this interface.

Snapshot validation, index preparation, and lookup all belong to this node. The lookup backend is an embedded SQLite database managed entirely locally within the kiosk filesystem.

## Snapshot Import and Index Construction

Snapshot ingestion processes an incoming snapshot package through the following steps:

1. **Validation**: Verify the signature manifest against a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness and structural validity.
2. **Staging**: Parse the newline-delimited JSON records and construct a temporary SQLite database file (`registry.db.tmp`).
3. **Schema and Indexing**:
   - `equipment` table:
     - `serial_number TEXT PRIMARY KEY` (storing uppercase normalized serial number)
     - `description TEXT NOT NULL`
     - `calibration_date TEXT NOT NULL`
     - `due_date TEXT NOT NULL`
   - `snapshot_metadata` table:
     - `snapshot_date TEXT NOT NULL`
     - `schema_version INTEGER NOT NULL`
4. **Activation**: Atomically rename the staging file to replace the active database (`registry.db`). Readers never observe an uncommitted or partially imported database.
5. **Failure Isolation**: If any validation check fails or index construction is interrupted, the staging file is discarded, the active database remains untouched, and an error is reported.

## Lookup Behavior and Query Path

1. **Input Normalization**: Trim leading and trailing whitespace and uppercase ASCII letters before querying. Serial-number punctuation (e.g., hyphens, slashes) remains significant.
2. **Query Execution**: Open `registry.db` in read-only mode and execute a parameterized query against `equipment` using the normalized serial number, reading the active `snapshot_date` from `snapshot_metadata`.
3. **Result Mapping**:
   - If a matching row is found, return `Found(record, snapshotDate)`.
   - If no matching row exists, return `NotFound(snapshotDate)`.
4. **Performance**: Index lookups on `serial_number PRIMARY KEY` resolve in well under 250 ms for 90,000 records on kiosk hardware with 4 GB RAM.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, managed search service | Satisfies the offline kiosk tenet requiring all lookups to complete using files on the kiosk with zero runtime network access; keeps 90,000 records searchable under 250 ms with low memory footprint; eliminates external network dependencies and service lifecycle management. |
| Snapshot activation strategy | Staging SQLite database with atomic file rename | In-place table updates within a transaction, direct sequential file scan | Atomic file rename guarantees readers never observe intermediate import states; completely isolates errors during import so the active snapshot is preserved unchanged. |

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`
```

---

### LLD Edge-Case Probe (Gaps & Questions)

#### 1. Missing State Transitions
- **Cold start before initial snapshot import**: What does `findBySerial` return when a kiosk boots up fresh and no snapshot has ever been imported (since `NotFound` expects an active `snapshotDate`)?
- **Interrupted import cleanup**: If a power failure leaves an orphaned `registry.db.tmp` or SQLite journal/WAL file on disk, how is cleanup handled on startup or subsequent import attempts?
- **In-flight readers during database swap**: When `registry.db.tmp` is atomically renamed over `registry.db`, does the lookup query path maintain open connection handles, reconnect per request, or handle file descriptor invalidation?
- **Rollback / snapshot age**: Does snapshot import permit activating a valid snapshot with a `snapshot_date` older than the currently active database, or must snapshot dates be strictly monotonic?
- **Empty valid snapshots**: If a validly signed snapshot contains zero records, does activating it displace existing inventory data?

#### 2. Unstated Invariants
- **Import concurrency**: Can multiple snapshot imports be triggered simultaneously (e.g., rapid media insertion), and is single-writer mutual exclusion required?
- **Storage exhaustion**: How does staging behave if the local disk lacks space for both the active database and the temporary staging file (~300 MB combined)?
- **Directory & file permissions**: Are specific file permissions required on `registry.db` to ensure read-only isolation across kiosk user accounts?

#### 3. Unspecified Error Shapes
- **Import API error contract**: What specific error types or variants are returned when import fails (e.g., `SignatureInvalid`, `UnsupportedSchemaVersion`, `DuplicateSerial`, `DiskFull`)?
- **Malformed lines / date validation**: Does snapshot validation verify date formats (ISO-8601) and field semantics before writing to SQLite, and does it fail fast on the first corrupt line or aggregate errors?
- **Corrupted active database**: How does `findBySerial` report or handle runtime SQLite file corruption if the active database is unreadable?

#### 4. Ordering & Normalization Edge Cases
- **Non-ASCII / Unicode serial numbers**: Does case normalization handle non-ASCII uppercase transformations or treat non-ASCII as exact match?
- **Empty input string**: Does `findBySerial("")` execute a lookup returning `NotFound(snapshotDate)` or fail immediately with an invalid input error?

---

Please review the design and indicate:
1. Which of the edge-case probe items you would like addressed in the LLD now versus deferred as open questions?
2. Whether this LLD is approved to proceed to Phase 3 (EARS spec updates).