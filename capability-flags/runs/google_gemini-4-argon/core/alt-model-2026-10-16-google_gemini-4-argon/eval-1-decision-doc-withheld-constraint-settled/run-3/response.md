I have updated `docs/intent/registry/registry-design.md` (and aligned the one-line summary in `docs/high-level-design.md`) to finalize the local embedded SQLite index design.

Because the HLD tenets prohibit runtime network access and require all lookups to complete from local kiosk files, the SQLite choice is settled by an inherited constraint and affects only the `registry` node—so I recorded it as a row in the LLD's **Decisions & Alternatives** table rather than creating a separate decision doc.

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

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The certificates node uses only this interface.

Snapshot validation, local SQLite index preparation, and lookup all belong to this node. The registry maintains an embedded SQLite database on local kiosk storage (`registry.sqlite`) containing snapshot metadata and a `records` table indexed by normalized serial number.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the replacement SQLite database in a staging file (`registry.staging.sqlite`), loading all records and creating the normalized serial-number index within a single transaction. Activate the new snapshot by atomically replacing the active SQLite file only after validation and index construction succeed. An import failure removes the staging file, leaves the previous active SQLite database untouched, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite database by the normalized serial number and read the snapshot date from the database metadata table in the same read transaction. Return `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | HLD tenets require all lookups to complete from local kiosk files with no runtime network access. An embedded SQLite index meets the 250 ms lookup target for 90,000 records on 4 GB RAM without external services or network dependencies, and supports atomic snapshot replacement via staged file swap. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please triage which of these component-level edge cases we should specify in the LLD now versus defer:

1. **Duplicate serial normalization**: Should serial-number uniqueness during snapshot import be enforced *after* normalization (e.g., `" ab-12 "` and `"AB-12"` collide as duplicates and fail the import), or on raw string values? If enforced on normalized values, should the original raw serial or only the normalized form be stored/returned in `record`?
2. **Concurrent lookup during atomic swap**: If a technician runs `findBySerial` at the exact moment a replacement snapshot is activated, how should open SQLite connections behave (e.g., open a short-lived read-only connection per lookup, or swap a shared connection handle under a lock)?
3. **Cold-start / no active snapshot**: What happens when `findBySerial` is called on a freshly provisioned kiosk before any valid snapshot has been imported, or if `registry.sqlite` is missing/corrupted on disk?
4. **Malformed records or missing fields**: If a signed snapshot passes signature and schema-version checks but contains a malformed JSON line or a record missing required fields (`serial`, `description`, `calibrationDate`, `dueDate`), should the entire snapshot import fail and roll back?
5. **Import error shape**: Does snapshot import return a structured error enum/code (e.g., `InvalidSignature`, `UnsupportedSchema`, `DuplicateSerial`, `MalformedRecord`, `StorageError`) so the kiosk UI can display specific remediation steps?
6. **Older or same-date snapshot import**: Should the registry allow importing a valid signed snapshot whose `snapshotDate` is older than the currently active snapshot (e.g., for rollback), or reject it?

How does the updated LLD look, and which of these probe items would you like folded into the design vs. deferred before we proceed to Phase 3?