Updated `docs/intent/registry/registry-design.md` with the local embedded SQLite index design (and removed the now-stale "remains open" note from `docs/high-level-design.md`). No decision doc is needed here—the HLD's offline kiosk constraints settle the backend choice and the decision is private to the registry node, so it is captured in the LLD's `Decisions & Alternatives` table.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed USB snapshot contains newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest. Kiosks operate offline with 4 GB of RAM, roughly 90,000 equipment records, snapshots up to 150 MB, and a 250 ms serial-number lookup target.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed, and the certificates node uses only this interface without reading registry storage directly.

Snapshot validation, local index construction, atomic activation, and serial-number lookup all belong to this node. The lookup backend is a local embedded SQLite database stored on the kiosk filesystem. No external service or network access is used during import or lookup.

## Local SQLite Index

Each active snapshot is stored as a self-contained SQLite database file on the kiosk:

- **`metadata` table**: single-row table storing `schema_version` and `snapshot_date` from the validated snapshot manifest.
- **`equipment` table**:
  - `normalized_serial TEXT PRIMARY KEY` — trimmed, ASCII-uppercased serial number (punctuation preserved)
  - `serial TEXT NOT NULL` — original serial number from the snapshot
  - `description TEXT NOT NULL` — equipment description
  - `calibration_date TEXT NOT NULL` — calibration date
  - `due_date TEXT NOT NULL` — calibration due date

Indexing on `normalized_serial` as the primary key provides B-tree lookups well within the 250 ms target for 90,000 records on 4 GB of RAM and enforces uniqueness on normalized serial numbers during import. Lookup queries open the active database in read-only mode.

## Snapshot Import

Import processes a snapshot from USB media in an isolated staging workflow:

1. **Signature verification**: Verify the snapshot signature manifest against the bundled public key before parsing records.
2. **Schema check**: Reject unsupported `schema_version` values.
3. **Streaming index build**: Create a fresh staging SQLite database file and stream-parse the NDJSON records inside a single write transaction so a 150 MB snapshot does not require loading all records into memory at once. Normalize each record's serial number before insertion and reject duplicate normalized serial numbers.
4. **Finalize and activate**: Write `metadata`, commit and fsync the staging database, close the write handle, and atomically swap the staging file into the active database location.

Activation occurs only after every validation and indexing step succeeds. On any failure—invalid signature, unsupported schema version, malformed record, duplicate serial number, or I/O error—delete the staging file, retain the previously active database untouched, and return a descriptive error.

## Lookup Behavior

Normalize the input serial number by trimming surrounding whitespace and uppercasing ASCII letters while preserving punctuation. Query `equipment` by `normalized_serial` and read `snapshot_date` from `metadata` on the active SQLite database. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks operate offline with no network route, ruling out networked directory and managed search services. Embedded SQLite runs in-process with no service to manage, meets the 250 ms lookup target for 90,000 records within 4 GB RAM, and keeps all storage and indexing private to the registry component. |
| Snapshot activation | Isolated staging database with atomic swap | In-place table rebuild in the active database | Building a separate staging SQLite file and swapping atomically ensures failed imports leave the previous snapshot intact and prevents partially imported records from being visible to lookups. |

## Open Questions & Future Decisions

### Deferred
- None currently tracked.
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please triage which of these internal gaps should be resolved in `registry-design.md` now versus deferred under `Open Questions & Future Decisions`:

1. **No active snapshot or unreadable database**: What happens when `findBySerial(serial)` is called before any snapshot has been imported (or if the active SQLite file is missing/corrupted), given that both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require a `snapshotDate`?
2. **Empty/whitespace serials and field validation**: What happens when an NDJSON record has an empty/whitespace-only `serial`, empty or `null` required fields, extra fields, or malformed date strings—and what happens when `findBySerial` receives an empty or whitespace-only string?
3. **Older, same-date, or empty snapshots**: What happens when a validly signed snapshot has a `snapshot_date` older than (or equal to) the active snapshot, or contains zero records?
4. **Concurrent lookups, SQLite sidecar files, and atomic swap**: What happens when a lookup holds an open read-only SQLite handle during an atomic file swap—how should journal/WAL/SHM sidecar files be handled (e.g., rollback journal mode deleted before close), and must staging live in the same directory/filesystem as the active file?
5. **Crash or power loss mid-import**: What happens if the kiosk loses power mid-import (leaving orphaned staging files behind) or immediately after rename without a parent-directory fsync?
6. **Concurrent imports and USB TOCTOU**: What happens if two imports run concurrently, or if the USB media is unplugged or altered between signature verification and streaming NDJSON parse?
7. **Import API/error shapes and resource limits**: Does the LLD need to define the import entrypoint signature and structured error categories (beyond "descriptive error"), or explicit behavior when disk space or SQLite page cache is exhausted on a 4 GB kiosk during a 150 MB import?

Let me know your feedback on the LLD and how you'd like to triage items 1–7, or confirm if you're ready to approve Phase 2 and move to Phase 3 (EARS specs).