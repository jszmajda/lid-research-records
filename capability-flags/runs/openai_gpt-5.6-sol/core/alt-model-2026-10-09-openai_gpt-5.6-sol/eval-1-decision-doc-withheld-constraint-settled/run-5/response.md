## Phase 2: Registry Design

Updated `docs/intent/registry/registry-design.md`:

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, or failing with `RegistryUnavailable` when no trustworthy active index can be queried. `RegistryUnavailable` is an operation error rather than a lookup result because no snapshot date can be asserted. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, index construction, activation, and lookup all belong to this node. Each kiosk maintains an embedded SQLite index built from its most recently activated snapshot. SQLite is an implementation detail behind `findBySerial`; the certificates node has no database dependency and no access to registry storage paths.

## Snapshot Import

Verify the snapshot manifest and payload signature using a bundled public key before trusting the snapshot contents. Reject unsupported schema versions, malformed records, invalid dates, missing required fields, and serial numbers that collide after lookup normalization.

Build each accepted snapshot into a new SQLite database at a staging path rather than modifying the active database. Import the newline-delimited JSON in one transaction, storing the normalized serial number as a unique lookup key alongside the record fields. Store the snapshot date as index metadata so Found and NotFound results are tied to the same activated generation. Create the serial-number index and run SQLite integrity checks before the staged database is eligible for activation.

After preparation succeeds, atomically replace the active database with the staged database. Lookups that began before activation may finish against the previous database; lookups that begin after activation use the replacement. The previous database remains active if validation, construction, integrity checking, or activation fails. Staging files left by an interrupted import are never treated as active and can be removed on the next import or application start.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Return the snapshot date even when no matching record exists.

Query the active SQLite database by its normalized unique key and map the row to the fixed registry result type. Keep lookup connections read-only. If no snapshot has ever been activated, or the active index cannot be queried reliably, fail with `RegistryUnavailable` rather than returning NotFound, because absence has not been established.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Embedded SQLite index on each kiosk | On-site HTTPS directory; managed search service | Keeps every lookup local and predictable, requires no service, credentials, or network failure handling, and satisfies the kiosk's offline operating constraints. Each kiosk accepts the cost of validating and rebuilding its own index when a snapshot arrives. |
| Index replacement | Build separately, then atomically activate | Update the active database in place | Prevents failed or interrupted imports from exposing a partial replacement and keeps the last valid snapshot usable. |
```

The LLD-level edge probe found these unresolved areas:

1. **Generation policy:** Should kiosks accept snapshots with the same, older, or future snapshot dates?
2. **Import concurrency and recovery:** What should happen with concurrent imports, interrupted activation, or a missing/corrupt active database at startup?
3. **Atomic replacement:** The exact safe mechanism depends on the kiosk OS and filesystem, including replacement of an open SQLite file and handling journal files.
4. **Snapshot contract:** The precise manifest, signed byte range, record schema, date formats, and key-rotation rules remain unspecified.
5. **Input and error contract:** Empty or invalid serial numbers and detailed import failures do not yet have defined result categories.
6. **Approved USB enforcement:** It is unclear whether the registry verifies approved media or whether media approval is an operational responsibility outside this component.

SQLite tuning, staging filenames, progress presentation, retry counts, and diagnostic wording can safely remain implementation details.

Please review the Phase 2 design and reply with approval or numbered feedback. For items 1–6, indicate which should be fixed in this LLD and which should be deferred.