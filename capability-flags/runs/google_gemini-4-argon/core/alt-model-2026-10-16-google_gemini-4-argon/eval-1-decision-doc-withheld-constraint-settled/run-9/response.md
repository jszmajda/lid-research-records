I've updated `docs/high-level-design.md` (closing the open lookup backend note under Architecture) and finished `docs/intent/registry/registry-design.md` around the local embedded SQLite index.

Because the HLD tenets already require file-based lookup on the kiosk with no runtime network access (eliminating the on-site HTTPS directory and managed search service), and the choice stays inside the `registry` component without affecting `certificates`, I recorded the backend selection as a row in the LLD's **Decisions & Alternatives** table rather than creating a standalone decision doc.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The certificates node uses only this interface; SQLite file paths, connection state, and schema details remain private to the registry component.

The active registry is stored as a local embedded SQLite database on the kiosk filesystem, containing a `metadata` table (`schema_version`, `snapshot_date`) and an indexed `equipment` table (`serial` primary key, `description`, `calibration_date`, `due_date`).

## Snapshot Import

Verify the signature manifest against the snapshot payload using the bundled public key, and reject unsupported schema versions before building the index.

Stage each incoming snapshot in a temporary SQLite database file in the same local directory as the active index:

1. Create a fresh staging SQLite file and initialize the `metadata` and `equipment` tables.
2. Stream the newline-delimited JSON records inside a transaction, normalizing each record's `serial` (trimming surrounding whitespace and uppercasing ASCII letters) before insertion. A `UNIQUE` constraint on `equipment.serial` detects duplicate normalized serial numbers.
3. Flush and close the staging database file.
4. Atomically replace the active SQLite database file with the validated staging file and reopen the read connection against the new index.

If signature verification, schema check, JSON parsing, or SQLite insertion fails, close and remove the staging file without modifying the active database file or read connection, and return an import error describing the failure.

## Lookup Behavior

Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters while preserving internal punctuation. Query the active SQLite database by primary-key lookup on `equipment.serial` alongside `metadata.snapshot_date`. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Keeps lookups predictable and within the 250 ms / 4 GB kiosk budget without runtime network access, which the isolated-kiosk tenets forbid; each kiosk validates and rebuilds its own SQLite index during snapshot import. |
| Atomic snapshot activation | Build index in a staging SQLite file and atomically replace the active file | In-place table swap inside a single SQLite file | Prevents a failed import or power loss during indexing from corrupting or locking the active snapshot, and keeps read lookups isolated until validation completes. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD above and let me know how you'd like to handle or defer these edge cases:

1. **No initial snapshot loaded (cold kiosk start)**: What should `findBySerial(serial)` return if a technician runs a lookup before any valid snapshot has ever been imported onto the kiosk (since `NotFound(snapshotDate)` requires a `snapshotDate`), or does the kiosk ship with a seed snapshot / block lookup until one is imported?
2. **Duplicate serial normalization during import**: The draft normalizes serial numbers (trim + uppercase ASCII) before insertion so `" ab-12 "` and `"AB-12"` collide as duplicates and fail the import. Should the stored/returned `record.serial` be the normalized form or preserve the original casing from the snapshot?
3. **Malformed or missing record fields**: If a record line in a signed snapshot has invalid JSON or is missing `serial`, `description`, `calibration_date`, or `due_date`, should the entire snapshot import fail and roll back, or can any fields be optional?
4. **In-flight lookup during snapshot swap**: When a new SQLite file replaces the active one, should lookups and imports be serialized (e.g., behind a lock/queue), or can read connections remain open against the previous file descriptor until the current query finishes?
5. **Leftover staging file on crash/power loss**: If the kiosk loses power mid-import, should startup or the next import automatically clean up any leftover staging SQLite file before staging a new snapshot?

Which of these should we fold into the LLD now vs. defer, and do you approve the LLD to proceed to Phase 3 (EARS specs)?