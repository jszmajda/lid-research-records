I updated `docs/high-level-design.md` (clearing the open-backend note on Registry) and completed `docs/intent/registry/registry-design.md` for the local embedded SQLite index. Because the HLD's offline/no-network tenets settle this choice and it stays isolated behind `findBySerial`, I recorded it in the LLD's **Decisions & Alternatives** table rather than creating a standalone decision doc.

### Updated Registry LLD (`docs/intent/registry/registry-design.md`)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Snapshot validation, local index preparation, and lookup are all encapsulated within this node.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `calibrationDate`, `dueDate`, `description`) and result types are fixed regardless of storage. The certificates node uses only this interface and never reads registry storage directly.

Store the active registry in a local embedded SQLite database file (`registry.db`) on kiosk storage. SQLite provides indexed primary-key lookups within the 250 ms latency budget on 4 GB RAM hardware for 90,000+ records and snapshots up to 150 MB, with no external service or network dependency.

## Storage Schema

The SQLite database contains two tables:

| Table | Column | Type | Notes |
|---|---|---|---|
| `snapshot_meta` | `schema_version` | `TEXT` | Validated snapshot schema version (single-row table) |
| `snapshot_meta` | `snapshot_date` | `TEXT` | ISO-8601 date of the active snapshot |
| `snapshot_meta` | `record_count` | `INTEGER` | Total records imported in this snapshot |
| `equipment_records` | `normalized_serial` | `TEXT PRIMARY KEY` | Trimmed, ASCII-uppercased serial; punctuation preserved |
| `equipment_records` | `serial` | `TEXT NOT NULL` | Original serial string from the snapshot |
| `equipment_records` | `calibration_date` | `TEXT NOT NULL` | Calibration date from the snapshot record |
| `equipment_records` | `due_date` | `TEXT NOT NULL` | Calibration due date from the snapshot record |
| `equipment_records` | `description` | `TEXT NOT NULL` | Equipment description from the snapshot record |

Because `normalized_serial` is the `PRIMARY KEY`, SQLite maintains a B-tree index on the normalized lookup key directly without a separate secondary index.

## Snapshot Import

Verify the snapshot manifest signature using the bundled public key before processing payload records, and reject unsupported schema versions.

Prepare the replacement index in a staging SQLite database file in the same directory as `registry.db`, outside the live read path:

1. Stream newline-delimited JSON records inside a single SQLite transaction.
2. Normalize each record's serial number (trim surrounding whitespace, uppercase ASCII letters, preserve punctuation) and insert into `equipment_records`. Uniqueness is enforced on `normalized_serial` so collisions are rejected even when casing or surrounding whitespace differs.
3. Write `snapshot_meta` with the snapshot's `schema_version`, `snapshot_date`, and `record_count`.
4. Close and flush (`fsync`) the staging database file.

Activate the new snapshot only after all validation and index building succeed by atomically renaming the staging file over the active `registry.db` path. On any signature, schema, parse, uniqueness, or I/O failure, delete the staging file, leave the previous `registry.db` active and unmodified, and return a descriptive error.

## Lookup Behavior

Normalize the query serial by trimming surrounding whitespace and uppercasing ASCII letters while preserving punctuation. Open a read-only query against the active `registry.db` to look up `normalized_serial` in `equipment_records` and read `snapshot_date` from `snapshot_meta`. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches. Always include the active `snapshotDate` in the result.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; Managed search service | Satisfies the kiosk offline and zero-network tenets; delivers predictable sub-250 ms indexed lookups for 90,000 records within 4 GB RAM without running a background service or managing external credentials. Index rebuilds stay isolated behind `findBySerial`. |

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`
```

### Phase 2 LLD Edge-Case Probe

A blind review of `registry-design.md` surfaced these internal gaps:

1. **First boot / no active snapshot**: What does `findBySerial(serial)` return or raise before any snapshot has been imported (when `registry.db` does not yet exist and there is no `snapshotDate`)?
2. **Corrupt or missing-table `registry.db`**: What error shape does `findBySerial` produce if `registry.db` is corrupt or `snapshot_meta` does not have exactly one row?
3. **Journal mode & concurrent lookup during swap**: Does SQLite use `DELETE` journal mode (not `WAL`, whose `-wal`/`-shm` sidecars would be orphaned across a file rename), and does each lookup open a fresh read-only connection so an open handle doesn't read an unlinked inode after atomic rename?
4. **Crash recovery & directory sync**: Does import clean up stale staging files from a prior crash (or use unique staging names) and `fsync` the parent directory after renaming?
5. **Manifest-to-payload binding**: Does the signed manifest include a cryptographic digest (e.g., SHA-256) of the NDJSON payload verified against the streamed bytes, so a valid manifest cannot be paired with a truncated or swapped payload?
6. **Blank serials & malformed record fields**: Are empty/whitespace-only serials rejected during import (and how are they handled on `findBySerial("")`), and are missing/non-string record fields or malformed JSON lines rejected?
7. **Import API & concurrent imports**: What is the import entry point's input/error contract, and are concurrent imports serialized or rejected?
8. **Disk/memory bounds on 150 MB import**: Should import enforce a preflight free-disk check (for active + staging DB) and a per-line size cap when streaming NDJSON on 4 GB RAM kiosks?

**Phase 2 stop:** Please review the updated LLD and let me know which of items 1–8 to resolve in `registry-design.md` now versus defer as open questions, and whether to proceed to Phase 3 (`registry-specs.md`).