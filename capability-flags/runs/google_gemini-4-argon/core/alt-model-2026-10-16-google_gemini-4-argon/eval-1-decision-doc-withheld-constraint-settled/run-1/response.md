I have updated `docs/intent/registry/registry-design.md` (and closed the open backend note in `docs/high-level-design.md`) to specify the local embedded SQLite index. Because the HLD tenets already require offline kiosk lookup with no runtime network access and the choice stays entirely within `registry`, I recorded the backend selection in the LLD's **Decisions & Alternatives** table rather than creating a separate decision doc.

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

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface.

Snapshot validation, local SQLite index preparation, and lookup all belong to this node. Each kiosk stores the active snapshot in a local embedded SQLite database on disk, with a unique index on normalized serial number and a metadata record holding the active `snapshotDate` and `schemaVersion`.

## Snapshot Import

Verify the signature using a bundled public key and reject unsupported schema versions before loading records. Build a fresh staging SQLite database in the kiosk's registry storage directory:

1. Stream newline-delimited JSON records from the snapshot, normalizing each serial number (trimming surrounding whitespace and uppercasing ASCII letters) on insert.
2. Enforce serial-number uniqueness via the SQLite unique index; abort the build if any duplicate normalized serial number or malformed record is encountered.
3. Write the snapshot metadata (`snapshotDate`, `schemaVersion`) and finalize the staging database.
4. Atomically swap the completed staging database into the active database path so queries see either the complete prior snapshot or the complete replacement snapshot.

If any validation or index-build step fails, remove the staging file, keep the existing active SQLite database untouched, and return a descriptive import error.

## Lookup Behavior

Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters before querying. Serial-number punctuation remains significant. Query the active SQLite database by indexed normalized serial number and read the snapshot date from the same database so the lookup result and snapshot date are always consistent. Return `Found(record, snapshotDate)` when a row matches, or `NotFound(snapshotDate)` when no row matches.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on snapshot import | On-site HTTPS directory; managed search service | Keeps all lookups local and deterministic within the 250 ms budget on 4 GB RAM without network access, external credentials, or service dependencies, as required by the offline kiosk architecture; accepts per-kiosk index rebuild work during USB snapshot import. |
| Snapshot activation | Build into a staging SQLite file and atomically swap into place | In-place table replacement inside the active database | Ensures failed imports leave the active snapshot untouched and prevents concurrent lookups from observing partially imported state or write locks during the 90,000-record load. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD and let me know which of these edge cases you want settled in the design vs. deferred as open questions:

1. **Duplicate detection on normalized vs. raw serials**: The draft enforces uniqueness on the *normalized* serial number (e.g., `" ab-12 "` and `"AB-12"` collide and fail the import). Should uniqueness be checked after normalization as drafted, or on the raw string?
2. **Lookup before any snapshot is imported**: What should `findBySerial` return on a freshly provisioned kiosk when no active SQLite database exists yet (where `NotFound(snapshotDate)` has no `snapshotDate` to report)—a distinct uninitialized error/state, or is a seed snapshot always bundled at provisioning?
3. **Concurrent lookup during file swap**: When a new staging SQLite file replaces the active database while a lookup is in flight, should `findBySerial` open a short-lived read connection per call (or switch an internal connection handle under a reader/writer lock) so in-flight queries finish cleanly against the old snapshot?
4. **Disk space / leftover staging files**: If a kiosk loses power mid-import or lacks space to hold both the active and staging SQLite databases, should startup/import sweep any leftover staging file before building a new index?
5. **Empty or missing required record fields**: If a JSON line is syntactically valid but missing `serial`, `calibrationDate`, `dueDate`, or `description` (or has an empty serial after trimming), should that reject the entire snapshot import under the same atomic rollback rule?

Please share your feedback on the LLD and these numbered points, and confirm when you are ready to proceed to Phase 3 (EARS updates).