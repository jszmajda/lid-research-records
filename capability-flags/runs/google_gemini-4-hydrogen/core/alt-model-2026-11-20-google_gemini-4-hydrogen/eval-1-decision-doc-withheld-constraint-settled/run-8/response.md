Updated `docs/intent/registry/registry-design.md` to use the local embedded SQLite index (and updated the one-line registry summary in `docs/high-level-design.md` so the HLD stays coherent).

Because HLD's offline/no-network tenets eliminate the network options and the backend stays private to `registry`, I recorded the choice in `Decisions & Alternatives` rather than proposing a standalone decision doc.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot from approved USB media contains newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest. Kiosks run offline with 4 GB of RAM, up to 90,000 records, and snapshots up to 150 MB, and must resolve serial-number lookups within 250 ms.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `description`, `calibrationDate`, `dueDate`) and result types are fixed. The certificates node uses only this interface; SQLite storage paths, schema, and import mechanics are private to this node.

Snapshot validation, SQLite index preparation, and lookup all belong to this node. On disk, the registry maintains an active SQLite database file and a temporary staging database path used only during snapshot import.

## SQLite Schema & Indexing

Each snapshot database contains two tables:

- `metadata`: single row holding `snapshot_date`, `schema_version`, and `record_count`.
- `equipment`: `serial TEXT PRIMARY KEY`, `description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, `due_date TEXT NOT NULL`.

The `serial` column stores the normalized serial number so point lookups use the primary-key B-tree index directly, keeping memory usage low and query latency well below the 250 ms target for 90,000 records. After building the staging database, the importer finalizes it into a self-contained single-file database so runtime lookups open it read-only without needing writeable WAL/SHM sidecar files.

## Snapshot Import

1. **Verify & validate**: Verify the signature manifest using the bundled public key, reject unsupported schema versions, and stream-parse the NDJSON records. Normalize each record's serial number and reject the import if any record is malformed or if duplicate normalized serial numbers appear.
2. **Stage**: Create a fresh SQLite database at a temporary staging path and insert all validated records inside a single transaction.
3. **Activate**: Flush and close the staging database, then atomically replace the active database path. If any step before activation fails, delete the staging file, leave the previous active snapshot untouched, and report a descriptive error.

Lookups continue reading the previous active database during staging and never observe a partially imported snapshot.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters in the query `serial` before lookup; serial-number punctuation remains significant. Query the `equipment` table by primary key and read `snapshot_date` from `metadata`, returning `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. If no snapshot has been imported yet, return an explicit uninitialized-registry error rather than fabricating a snapshot date.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; Managed search service | Kiosks operate without runtime network access and must resolve lookups from local files. An embedded SQLite database satisfies the offline constraint, keeps all index state private to the registry node, and provides fast indexed point lookups within the 4 GB RAM budget without external services or credentials. |
| Snapshot activation | Staged SQLite build with atomic swap | In-place `DELETE` and `INSERT` on the active database | Building a separate staging database avoids mutating the live index during validation and guarantees that a failed or interrupted import leaves the previous active snapshot intact. |

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
```

### Phase 2 LLD Edge-Case Probe

A blind edge-case probe of `registry-design.md` surfaced these internal gaps:

1. **Concurrent lookup vs. atomic swap:** What happens when `findBySerial(serial)` is in flight—or holds a read-only SQLite connection—when `Activate` atomically replaces the active database file?
2. **Concurrent snapshot imports:** What happens when two snapshot imports are triggered concurrently—are they serialized, is the second rejected immediately, or could they race on the staging path?
3. **Crash recovery and corrupt active storage:** What happens when a prior crash leaves a stale staging file on disk before the next import, or when the active SQLite file is corrupt or missing its `metadata` row during lookup?
4. **Empty and non-ASCII serial inputs:** What happens when `findBySerial(serial)` receives an empty string, whitespace-only string, or non-ASCII whitespace/letters (`NotFound` vs. input error), and are records whose `serial` normalizes to empty rejected on import?
5. **Zero-record snapshots, count mismatches, and size bounds:** What happens when a signed snapshot has zero NDJSON records, a `record_count` mismatch, or exceeds 150 MB?
6. **Snapshot date ordering and record field validation:** What happens when a valid signed snapshot has an older `snapshot_date` than the active snapshot (downgrade/replay), or when record fields are empty, use unexpected date formats, or include unknown JSON fields?
7. **Import API and error shapes:** What is the import entry-point signature/packaging (separate files vs. bundle) and what are the concrete error shapes for `findBySerial(serial)` (e.g., uninitialized vs. corrupt DB) and import failures?

### Next

Please review `registry-design.md` and let me know:
1. Which of the numbered edge-case items above you want specified in `registry-design.md` now vs. deferred as open questions.
2. Whether you approve this LLD (after any edits) to proceed to **Phase 3 (EARS specs update)**.