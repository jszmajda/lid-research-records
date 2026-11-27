The registry low-level design (`docs/intent/registry/registry-design.md`) has been updated to specify the local embedded SQLite index, and the reference in `docs/high-level-design.md` has been aligned.

### Updated Registry LLD (`docs/intent/registry/registry-design.md`)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry component operates strictly offline on isolated production kiosks with 4 GB of RAM. It provides predictable serial-number lookups under 250 ms across ~90,000 records without external network services or background daemons.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.

Record structure:
- `serial`: Equipment serial number (original string).
- `description`: Equipment description.
- `calibrationDate`: Date of last calibration.
- `dueDate`: Date calibration is due.

The certificates node relies exclusively on this interface. Internal storage mechanisms, SQLite schema, query execution, and file paths are fully encapsulated within the registry component.

## Storage and Index Schema

The active registry is stored in a local SQLite database file on kiosk storage.

### Schema Structure

- **`snapshot_meta` table**:
  - `snapshot_date` (TEXT): Date the snapshot was generated.
  - `schema_version` (INTEGER): Schema version of the snapshot.
  - `record_count` (INTEGER): Total count of equipment records.
  - `imported_at` (TEXT): Timestamp when the snapshot was activated on this kiosk.

- **`equipment` table**:
  - `serial_normalized` (TEXT, PRIMARY KEY): Normalized serial number for exact lookups.
  - `serial_raw` (TEXT, NOT NULL): Preserved original serial number format.
  - `description` (TEXT, NOT NULL): Equipment description.
  - `calibration_date` (TEXT, NOT NULL): Calibration date string.
  - `due_date` (TEXT, NOT NULL): Calibration due date string.

The primary key on `serial_normalized` provides direct B-tree indexed lookups satisfying the sub-250 ms response requirement for 90,000 records on low-spec hardware.

## Snapshot Import and Index Lifecycle

Snapshots arrive via approved USB media as signed archives containing newline-delimited JSON records, metadata, and a cryptographic signature manifest.

### Validation Sequence

1. **Signature Verification**: Verify the snapshot archive signature against a bundled public key before processing records. Reject unverified or tampered archives.
2. **Schema Compatibility**: Confirm the snapshot schema version is supported by the current registry component.
3. **Data Integrity & Uniqueness**: Parse records and verify all mandatory fields are present and valid. Verify serial numbers are unique after normalization across the entire snapshot; reject imports containing duplicate normalized serials.

### Staging and Atomic Activation

- Build the SQLite index in a separate staging database file on local disk.
- Insert records and construct indexes within a single database transaction.
- Verify table integrity and record count against snapshot metadata.
- Perform an atomic file rename/replacement to swap the staging database into the active database path.
- Once replaced, update any cached database connections or metadata handles.

### Failure Handling and Rollback

If validation fails at any point—corrupted signature, unsupported schema, duplicate serial numbers, malformed JSON, or database write failure:
- Abort the import immediately.
- Clean up all temporary and staging files.
- Keep the existing active SQLite database completely intact and available for ongoing lookups.
- Return a structured diagnostic error detailing the cause of rejection.

## Lookup Behavior

### Input Normalization

Prior to querying the database, the input serial string is normalized:
- Strip leading and trailing whitespace.
- Convert ASCII letters to uppercase.
- Preserve all internal punctuation, dashes, slashes, and spaces.

### Query Execution

Execute an exact point lookup against `equipment` using the normalized serial:
```sql
SELECT serial_raw, description, calibration_date, due_date
FROM equipment
WHERE serial_normalized = ?;
```

### Result Formation

- **Found**: Returns `Found(record, snapshotDate)` with the matched record details and the active `snapshot_date`.
- **NotFound**: Returns `NotFound(snapshotDate)` with the active `snapshot_date`.
- Both result paths include the active snapshot date retrieved from `snapshot_meta`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, Managed search service | Predictable lookup latency (<250 ms) on isolated kiosks with 4 GB RAM. Operates with zero runtime network access, satisfying kiosk isolation tenets. Index validation and atomic replacement remain entirely self-contained within the registry component without external service dependencies, daemon management, or network timeout handling. |

## Open Questions & Future Decisions

### Resolved
1. Lookup backend selected as local embedded SQLite index.
2. Snapshot import uses staging file and atomic rename to guarantee zero exposure of partially imported data.
3. Metadata table tracks active snapshot date and record count alongside records.

### Deferred
1. Minimum free disk space requirement on kiosk storage prior to accepting a 150 MB snapshot staging build.
2. Handling of open SQLite read locks if a lookup is executing during atomic file replacement.
```

---

### Phase 2 LLD Edge-Case Probe Findings

An edge-case probe across the component's internal state boundaries surfaced the following questions:

1. **Uninitialized / Cold Start State**: What should `findBySerial(serial)` return if invoked before any initial snapshot has ever been imported on a kiosk, or if the database file is absent?
2. **Connection Lifecycle Across Swaps**: How should cached SQLite connection handles or active read queries behave when the staging file is renamed over the active file?
3. **Mid-Import Interruption Recovery**: If power is cut during staging build, what startup routine cleans orphaned staging files to prevent disk exhaustion?
4. **Database Corruption / Read Errors**: Does `findBySerial` need an explicit error variant for disk I/O errors / corrupt database pages, or should that be handled as an unhandled failure?
5. **Non-ASCII / Character Set Invariants**: Are non-ASCII letters or diacritics permitted in serial numbers, and should normalization or collation enforce ASCII-only or UTF-8 NOCASE rules?
6. **Date Format Validation**: What exact date format string (e.g., ISO-8601 `YYYY-MM-DD`) must the import validator enforce on `snapshot_date`, `calibration_date`, and `due_date`?

---

How would you like to triage these probe questions (which should be incorporated directly into the LLD vs. kept deferred), and do you approve proceeding to Phase 3 (EARS specs)?