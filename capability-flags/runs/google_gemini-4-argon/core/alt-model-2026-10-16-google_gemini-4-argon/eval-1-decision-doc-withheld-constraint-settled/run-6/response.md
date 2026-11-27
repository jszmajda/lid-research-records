I have updated `docs/intent/registry/registry-design.md` (and removed the open-backend note from `docs/high-level-design.md`) to finalize the local embedded SQLite index design. Because the HLD tenets and non-goals already mandate offline kiosk operation with no runtime network access and because the choice stays internal to the registry component, I recorded the selection as a row in the LLD's `Decisions & Alternatives` table rather than creating a standalone decision doc.

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

Snapshot validation, local embedded SQLite index construction, and lookup all belong to this node.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a new SQLite database file in a staging path from the snapshot's newline-delimited JSON records, writing the normalized serial number as the primary key alongside the record fields and storing the snapshot date and schema version in metadata. Activate the new index by atomically replacing the active SQLite database file only after all validation and index construction succeed. An import failure discards the staged database, leaves the previous snapshot active, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active local SQLite index by normalized serial number and return the active snapshot date alongside `Found` or `NotFound`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks operate without runtime network access per the HLD tenets and non-goals, eliminating networked backends; an embedded SQLite file built during snapshot import meets the 250 ms lookup and 4 GB RAM goals for 90,000 records and enables atomic snapshot activation via file replacement. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please let me know which of these LLD-level edge cases we should settle in the design now versus defer as open questions:

1. **Duplicate serial numbers after normalization:** Should uniqueness validation during snapshot import check raw serial strings or normalized serial strings (trimmed + ASCII uppercase), and when a record is returned in `Found(record, snapshotDate)`, should `record.serial` preserve the original snapshot casing or the normalized form?
2. **Cold-start state before any snapshot is imported:** What happens when `findBySerial(serial)` is called on a freshly provisioned kiosk that has no active SQLite index yet (e.g., return a distinct `Uninitialized` / error state, or require a pre-seeded snapshot at installation)?
3. **Concurrent lookup during snapshot activation:** If a lookup is in flight while a newly built SQLite file replaces the active one, how should connection handover work so the in-flight query completes cleanly against a consistent snapshot?
4. **Malformed records or missing required fields:** If a signed snapshot has a valid signature and schema version but contains malformed JSON lines, missing required fields (`serial`, `description`, `calibrationDate`, `dueDate`), or unparseable dates, should the entire snapshot import fail and roll back?
5. **Older snapshot rollback protection:** If a technician imports a validly signed USB snapshot whose `snapshotDate` is older than the currently active snapshot, should the registry reject it, warn, or allow the replacement?
6. **Import error shape:** What structured error categories should snapshot import return so the kiosk UI can give actionable feedback (e.g., `InvalidSignature`, `UnsupportedSchemaVersion`, `DuplicateSerial`, `MalformedRecord`, `StorageError`)?

Please review the updated LLD and let me know your rulings on the probe items above so we can incorporate them and proceed to Phase 3 (EARS specs).