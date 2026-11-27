Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (with the choice recorded in its Decisions & Alternatives table) and removed the stale "Its private lookup backend remains open" note from `docs/high-level-design.md`. `docs/intent/certificates/` is unchanged.

---

### Phase 2 Output: `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest. Kiosks operate offline with 4 GB of RAM and serve roughly 90,000 equipment records from snapshots up to 150 MB.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields (`serial`, `description`, `calibrationDate`, `dueDate`) and result types are fixed regardless of internal storage. The certificates component depends only on this interface and has no visibility into storage paths, schema, or query mechanics.

Snapshot validation, index construction, atomic activation, and serial-number lookup are all private to this component and backed by a local embedded SQLite database stored on the kiosk.

## Local SQLite Index

Each active snapshot is materialized as a self-contained local SQLite database file containing:

- **`metadata` table** (single row): `snapshot_date`, `schema_version`, and snapshot manifest digest.
- **`records` table**:
  - `normalized_serial TEXT PRIMARY KEY` — trimmed, ASCII-uppercased serial number (punctuation preserved).
  - `raw_serial TEXT NOT NULL` — original serial number from the snapshot.
  - `description TEXT NOT NULL` — equipment description.
  - `calibration_date TEXT NOT NULL` — calibration date.
  - `due_date TEXT NOT NULL` — calibration due date.

Because `normalized_serial` is the primary key (B-tree index), point lookups execute in O(log n) time with minimal memory overhead, staying well within the 250 ms lookup goal for 90,000 records on 4 GB RAM kiosks. Lookup connections open the active database in read-only mode.

## Snapshot Import

Snapshot import builds a complete replacement SQLite database in a staging location on the same filesystem before touching the active database:

1. **Signature & manifest verification**: Verify the snapshot signature against the bundled public key before parsing records.
2. **Schema check**: Reject unsupported schema versions immediately.
3. **Staging build & validation**: Stream NDJSON records into a newly created staging SQLite database inside a single transaction, normalizing each serial number on insert. The `PRIMARY KEY` constraint on `normalized_serial` enforces uniqueness (including collisions after whitespace/case normalization); any duplicate serial number, malformed record, or I/O error aborts the transaction and deletes the staging file.
4. **Atomic activation**: Once all records and metadata are committed and the staging database passes an integrity check, flush and close the staging file, then atomically replace the active database pointer/file so concurrent or subsequent lookups see either the entire previous snapshot or the entire new snapshot—never a partial state.

Any failure at any step leaves the previously active SQLite database untouched and returns a structured import error identifying the failure reason.

## Lookup Behavior

1. Normalize the input serial number by trimming leading/trailing whitespace and uppercasing ASCII letters; punctuation remains significant.
2. Query the active SQLite database for `normalized_serial` and read `snapshot_date` from `metadata` within the same read transaction so the record and snapshot date are always from the same snapshot.
3. Return `Found(record, snapshotDate)` if a row matches, or `NotFound(snapshotDate)` if no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | HLD tenets require fully offline lookup with no runtime network route, which eliminates networked directory and cloud search services. Embedded SQLite delivers predictable sub-250 ms point lookups over 90,000 records within 4 GB RAM, requires no separate service or credentials, and keeps index validation and rebuilds private to the registry component. |
| Snapshot activation | Build staging SQLite file, then atomic swap | In-place `DELETE`/`INSERT` on active DB | Building a separate staging file guarantees a failed import (corrupt NDJSON, duplicate serials, disk full, crash) cannot corrupt or partially expose data in the active database, and allows an integrity check before activation. |
```

---

### Phase 2 LLD Edge-Case Probe

A subagent probed `registry-design.md` for internal structural gaps:

1. **Cold-start & corrupt active DB**: What happens when `findBySerial(serial)` is called before any snapshot has ever been imported, or if the active SQLite file is missing/corrupt? Both `Found` and `NotFound` require a `snapshotDate`.
2. **Swap mechanics & concurrency**: What happens when atomic activation runs while read-only lookup transactions are open, or when two imports are triggered concurrently? (Versioned DB files + pointer vs. in-place file rename, plus import serialization.)
3. **Snapshot ordering & re-import**: What happens when a valid signed snapshot has a `snapshot_date` older than the active snapshot (downgrade/rollback) or an identical manifest digest?
4. **Record-level & NDJSON validation**: What happens on an empty snapshot (0 records), blank lines, unknown JSON fields, empty/whitespace-only required fields, non-ISO dates, or `dueDate < calibrationDate`?
5. **Normalization & returned `serial`**: Which value (`raw_serial` or `normalized_serial`) is returned in `Found(record, snapshotDate)`? How should Unicode/internal whitespace or empty-after-trim lookup inputs be handled?
6. **Crash cleanup & verify-then-stream TOCTOU**: What cleans up orphaned staging files after a crash/power loss, and does step 3 read the exact verified byte stream checked in step 1 (in case USB media changes or disconnects mid-import)?
7. **Import entry-point & error schema**: What are the import function's signature, bundle input shape, success payload, and enumerated error variants?

---

### Phase 2 Review

1. Which of the edge-case probe items (1–7) should be resolved in `registry-design.md` now, and which should be deferred as open questions?
2. Any other edits to `docs/intent/registry/registry-design.md` before we approve Phase 2 and move to Phase 3 (EARS specs)?