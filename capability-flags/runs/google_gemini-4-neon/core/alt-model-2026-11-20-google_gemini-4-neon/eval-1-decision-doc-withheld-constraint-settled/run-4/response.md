Updated `docs/intent/registry/registry-design.md` with the local embedded SQLite index design (and removed the stale "private lookup backend remains open" note in `docs/high-level-design.md`). The backend choice is recorded in the LLD's **Decisions & Alternatives** table.

### Phase 2 Output — `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. The registry must handle approximately 90,000 records and snapshots up to 150 MB on kiosks with 4 GB of RAM, resolving lookups within 250 ms using only local kiosk files.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed and independent of storage. The certificates component uses only this interface and does not read registry storage directly.

Snapshot validation, index preparation, and lookup all belong to this node and are backed by a local embedded SQLite database file stored on the kiosk. Each validated snapshot is compiled into its own self-contained SQLite database file so that the active index is read-only during lookups and replacement happens atomically.

## Local SQLite Index

Each snapshot database contains two tables:

- `metadata`: stores snapshot-level attributes (`snapshot_date`, `schema_version`, and manifest signature digest) for the active snapshot.
- `records`: stores one row per equipment item with `normalized_serial TEXT PRIMARY KEY`, `serial TEXT NOT NULL`, `equipment_description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, and `due_date TEXT NOT NULL`.

Because `normalized_serial` is the primary key, SQLite maintains a B-tree index over all ~90,000 serial numbers, giving predictable sub-millisecond point lookups well within the 250 ms budget without holding the full dataset in application memory. Active snapshot databases are opened read-only for lookups.

## Snapshot Import

Snapshot import builds a new index without touching the active database:

1. Verify the snapshot signature against the bundled public key before parsing records.
2. Check that the snapshot's `schema_version` is supported and that required manifest metadata (including `snapshot_date`) is present.
3. Create a staged SQLite database file in the registry's local storage directory and stream the newline-delimited JSON records into it within a single write transaction to bound memory use on snapshots up to 150 MB.
4. For each record, normalize its serial number (trim surrounding whitespace, uppercase ASCII letters, preserve punctuation), validate required fields, and insert into `records`. Duplicate normalized serial numbers fail the primary-key uniqueness check and abort the import.
5. Write the `metadata` row, commit the transaction, flush the staged file to disk, and close the write connection.
6. Atomically activate the staged database as the current snapshot (switching the active database reference) so all records and the updated `snapshot_date` become visible together.

If any step fails, discard the staged SQLite file, leave the previous snapshot active and unmodified, and report a descriptive error.

## Lookup Behavior

1. Normalize the input serial number by trimming surrounding whitespace and uppercasing ASCII letters; serial-number punctuation remains significant.
2. Query `records` in the active SQLite database by `normalized_serial` and read `snapshot_date` from the active snapshot's `metadata`.
3. Return `Found(record, snapshotDate)` if a row matches, or `NotFound(snapshotDate)` if no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks have no runtime network route and disallow cloud or remote services; only a local backend satisfies the offline constraint. SQLite requires no external service, delivers predictable indexed lookups within the 250 ms and 4 GB RAM budgets, and keeps index lifecycle private to this node. |
| Snapshot activation strategy | Build a staged SQLite file per snapshot and activate atomically | Mutate or reload the active SQLite database in place | Building a separate file isolates validation and I/O failures so lookups never observe a partially imported snapshot and the prior snapshot remains available on failure. |
| Serial-number indexing | Store normalized serial as `PRIMARY KEY` | Runtime case-folding or SQLite collation on raw serial | Pre-normalizing on import guarantees that uniqueness validation and lookup matching apply identical rules while enabling direct B-tree primary-key lookups. |
```

### Phase 2 LLD-Level Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and triage which of these internal gaps to resolve in the LLD now vs. defer as open questions:

1. **Uninitialized or unreadable active index:** What happens when `findBySerial(serial)` is called on a fresh kiosk before any snapshot has been imported, or if the active SQLite file is missing or corrupted on disk (given the interface currently names only `Found` and `NotFound`)?
2. **Crash recovery and active-pointer persistence:** What happens if the kiosk loses power mid-import or during activation—how is the active snapshot pointer persisted across restarts, and when are orphaned staged SQLite files cleaned up?
3. **In-flight lookups during activation and disk cleanup:** What happens when a `findBySerial(serial)` query is reading the previous SQLite file while a new snapshot activates, and when are superseded snapshot files deleted so repeated imports do not fill the disk?
4. **Overlapping snapshot imports:** What happens if a second snapshot import is triggered while an import is already in progress (reject as busy, serialize, or isolate)?
5. **Older or replayed snapshots:** What happens when a validly signed snapshot has a `snapshot_date` earlier than (or equal to) the currently active snapshot—reject as rollback/replay, or allow?
6. **USB removal or modification between verification and streaming:** What happens if the USB media is removed or changes between signature verification (Step 1) and streaming the NDJSON records (Step 3)—should the snapshot be copied/verified from a single local staging copy or verified in a single streaming pass?
7. **Degenerate inputs and structured error shapes:** What happens on a zero-record snapshot, records with empty/whitespace-only required fields or malformed dates, or an empty/whitespace-only `serial` passed to `findBySerial`, and what error shapes should import and lookup return?

Let me know your triage on these items and any edits to the LLD; once approved, I will proceed to Phase 3 (`docs/intent/registry/registry-specs.md`).