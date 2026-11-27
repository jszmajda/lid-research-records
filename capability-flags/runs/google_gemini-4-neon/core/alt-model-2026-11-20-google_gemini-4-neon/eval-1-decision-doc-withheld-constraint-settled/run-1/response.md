Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite backend and recorded the choice in its **Decisions & Alternatives** table. Also updated the Registry bullet in `docs/high-level-design.md` to drop the stale "backend remains open" note; `certificates` is unaffected.

### Phase 2 — Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot delivered on approved USB media contains newline-delimited JSON (NDJSON) records (approximately 90,000 records, up to 150 MB), a schema version, a snapshot date, and a signature manifest. Kiosks operate offline with 4 GB of RAM and must resolve lookups within 250 ms.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `description`, `calibrationDate`, `dueDate`) and result types are fixed; the certificates component depends only on this interface and never reads registry storage directly.

The registry is backed by a local embedded SQLite database stored on the kiosk. Snapshot validation, index building, and serial-number lookup all live inside this component, with no external service or runtime network dependency.

## Storage Schema & Indexing

Each active snapshot is stored as a self-contained SQLite file containing two tables:

- **`metadata`** (single row): `snapshot_date TEXT NOT NULL`, `schema_version TEXT NOT NULL`, `imported_at TEXT NOT NULL`.
- **`equipment`**:
  - `normalized_serial TEXT PRIMARY KEY` — trimmed, ASCII-uppercased serial number with punctuation preserved; the B-tree primary key serves point lookups directly.
  - `serial TEXT NOT NULL` — original serial number from the snapshot record.
  - `description TEXT NOT NULL` — equipment description.
  - `calibration_date TEXT NOT NULL` — last calibration date.
  - `due_date TEXT NOT NULL` — next calibration due date.

Lookup connections open the active SQLite file read-only so normal kiosk queries cannot mutate registry data and keep memory footprint predictable on 4 GB hardware.

## Snapshot Import

Import validates and indexes an incoming USB snapshot into a staged SQLite file before activating it:

1. **Signature verification**: Verify the snapshot's signature manifest against the bundled public key before reading records. Reject snapshots with missing or invalid signatures.
2. **Schema check**: Reject snapshots whose `schema_version` is not supported.
3. **Staged build**: Create a new temporary SQLite file in the kiosk's registry storage directory (on the same filesystem as the active database). Stream-parse the NDJSON records so peak memory stays bounded on 4 GB kiosks, normalize each serial number, and insert all rows inside a single transaction.
4. **Uniqueness validation**: Enforce uniqueness on `normalized_serial` via the primary key constraint; any duplicate normalized serial number rejects the entire import.
5. **Atomic activation**: Write the `metadata` row, commit and flush the staged SQLite file to disk, and atomically swap it into place as the active database so lookups observe either the complete previous snapshot or the complete new snapshot.
6. **Failure handling**: On any validation, parse, constraint, or I/O failure, abort the build, remove the temporary staged file, leave the previous active SQLite file intact, and return a descriptive error.

## Lookup Behavior

Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters while preserving punctuation. Query the active SQLite database read-only by `normalized_serial` and read `snapshot_date` from `metadata`. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks have no runtime network route and must resolve lookups strictly from local files. An embedded SQLite file keeps lookups predictable (<250 ms for 90,000 rows within 4 GB RAM) with no service, credentials, or network dependency; per-kiosk validation and index rebuild stay encapsulated inside the registry component. |
| Snapshot activation | Staged SQLite file build with atomic swap | In-place table replacement inside a single SQLite file | Building into a separate file on the same filesystem and swapping atomically ensures a failed or interrupted import never corrupts or partially exposes the active snapshot. |
| Serial uniqueness key | Primary key on `normalized_serial` | Uniqueness on raw serial string only | Lookups match on normalized serial numbers; enforcing uniqueness on the normalized form prevents ambiguous matches from case or whitespace variations in source snapshots. |
```

### LLD-Level Edge-Case Probe

Please triage which of these gaps to address in the LLD now vs. defer to **Open Questions & Future Decisions**:

1. **No-snapshot / bootstrap state**: What happens when `findBySerial` is called on a freshly provisioned kiosk before any snapshot has been imported (no active SQLite file or `snapshotDate` exists)?
2. **Corrupt or unreadable active DB at lookup**: What happens when `findBySerial` encounters a corrupt/truncated/unreadable active SQLite file, or a `metadata` table with 0 or >1 rows?
3. **Concurrency during swap & overlapping imports**: What happens when a read-only lookup connection is open during atomic swap (per-query vs. pooled connections, and journal/WAL sidecar handling), or when two imports are triggered concurrently?
4. **Crash / power-loss cleanup**: What happens to orphaned staged SQLite files left behind by a crash or power loss mid-import?
5. **Snapshot date rollback / re-import**: What happens when a validly signed snapshot has a `snapshot_date` older than or equal to the active snapshot—should it be rejected or allowed?
6. **Boundary & malformed inputs**: What happens on a 0-record snapshot, empty/whitespace-only `serial` or required fields, malformed dates (or `due_date < calibration_date`), extra/missing JSON fields, or an empty/whitespace-only query to `findBySerial`?
7. **Signature scope, size limit, & USB TOCTOU**: What happens if a snapshot exceeds 150 MB, if NDJSON/metadata diverges from the signed manifest, or if the USB drive is modified/unplugged between signature verification and streaming parse?

Let me know any edits to the LLD and how you'd like to triage items 1–7, or approve Phase 2 to proceed to Phase 3 (`docs/intent/registry/registry-specs.md`).