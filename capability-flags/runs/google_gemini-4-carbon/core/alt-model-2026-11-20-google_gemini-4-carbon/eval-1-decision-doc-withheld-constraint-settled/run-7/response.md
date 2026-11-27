`docs/intent/registry/registry-design.md` is updated for the local embedded SQLite index (with the backend choice recorded in `Decisions & Alternatives`), and `docs/high-level-design.md` has a one-line coherence update removing `"Its private lookup backend remains open."` while keeping storage layout private to Registry. The `certificates` segment is unaffected because `findBySerial(serial)` is unchanged.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians on offline metrology kiosks enter an equipment serial number and need its calibration date, due date, and equipment description. The registry holds approximately 90,000 equipment records delivered on approved USB media in snapshots up to 150 MB, and lookups must resolve within 250 ms on a kiosk with 4 GB of RAM. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The certificates component depends only on this interface; SQLite schema, index files, staging paths, and snapshot verification remain private to the registry component.

Snapshot validation, local SQLite index preparation, atomic activation, and serial-number lookup all belong to this node. No separate database daemon or network service runs on the kiosk.

## Storage and Index Layout

Each activated snapshot is stored as a self-contained SQLite database file on local kiosk storage containing:

- `records`: keyed by normalized serial number (`PRIMARY KEY` B-tree index), storing the canonical serial number, equipment description, calibration date, and due date.
- `snapshot_meta`: a single-row table storing `snapshot_date` and `schema_version`, keeping the snapshot date bound to the indexed records in the same file.

An on-disk SQLite B-tree keeps steady-state memory usage small within the 4 GB kiosk budget while serving primary-key point lookups within 250 ms across 90,000 records.

## Snapshot Import

1. Verify the signature manifest against the snapshot payload using the bundled public key and reject unsupported schema versions before indexing any records.
2. Stream the newline-delimited JSON records into a fresh staging SQLite file in the local registry storage directory inside a single write transaction, normalizing each record's serial number for the primary key so duplicate serial numbers fail validation.
3. Finalize the staging database as a self-contained single-file SQLite image (no external WAL sidecar files), populate `snapshot_meta`, commit and sync the database file to disk, close the write connection, atomically rename it onto the active database path on the same local filesystem, sync the parent directory, and swap the active read-only database handle so subsequent lookups read the new file while any in-flight lookup finishes against its existing handle.
4. If signature verification, schema validation, record parsing, serial uniqueness, or index creation fails, remove the staging file, keep the previously active SQLite database serving lookups, and return a descriptive import error.

## Lookup Behavior

Normalize `serial` by trimming surrounding whitespace and uppercasing ASCII letters (`a`–`z` to `A`–`Z`); internal whitespace and serial-number punctuation remain significant. Using the current read-only database handle inside a single read transaction, query `snapshot_date` from `snapshot_meta` and perform a prepared primary-key lookup on `records` by the normalized serial number. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no matching row exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on snapshot import | On-site HTTPS directory; managed search service; raw NDJSON scan or full in-memory map | Kiosks operate without runtime network access, ruling out the on-site HTTPS directory and managed search service; an on-disk SQLite B-tree meets the 250 ms lookup target over 90,000 records and 150 MB snapshots within 4 GB RAM and swaps atomically as a single file, at the cost of rebuilding the local index on each kiosk during USB import. |
```

---

### Phase 2 LLD Edge-Case Probe

A blind subagent probed `registry-design.md` for internal component gaps. Please let me know which items you want settled in the LLD now versus deferred under `Open Questions & Future Decisions`:

1. **Cold-start lookup (no snapshot imported yet)**: What happens when `findBySerial(serial)` is called on a freshly provisioned kiosk before any snapshot has been imported, given both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require a `snapshotDate` (e.g., an `Uninitialized` result/error state, or a required factory-seeded snapshot)?
2. **Import entry point and runtime error shapes**: What is the registry's snapshot-import entry point signature and USB package input shape (directory path vs. single archive), and how should import failures or unexpected SQLite read I/O errors be surfaced (structured error variants vs. error messages/exceptions)?
3. **Snapshot date rollback / replay**: What happens when a validly signed snapshot has a `snapshot_date` older than or equal to the currently active `snapshot_date` — reject older snapshots, or allow any validly signed snapshot to replace the active index?
4. **Signature coverage and USB read staging**: Does the signature manifest cover `schema_version` and `snapshot_date` in addition to the NDJSON records, and should import stage/verify bytes locally in one pass so USB removal or mutation mid-read cannot split verification from indexing?
5. **Record validation and canonical serial representation**: What happens during import if a record has an empty/whitespace-only serial, missing/malformed fields (`description`, `calibrationDate`, `dueDate`), or if a snapshot has 0 records — and in `Found(record, snapshotDate)`, should `record.serial` hold the normalized uppercase key or the original serial string (trimmed or raw) from the JSON record?
6. **Concurrent imports and orphaned staging files**: What happens if a second import is triggered while an import is already in progress (serialize vs. reject as busy), or when leftover staging files exist after a power loss or `ENOSPC` failure?
7. **150 MB snapshot bound**: What happens when a snapshot on USB exceeds 150 MB — enforce a hard pre-import size cap, or treat 150 MB solely as a performance/sizing target?

---

**Phase 2 review stop:** Please share your feedback on `registry-design.md` and how you'd like to triage items 1–7 above before I proceed to Phase 3 (`docs/intent/registry/registry-specs.md`).