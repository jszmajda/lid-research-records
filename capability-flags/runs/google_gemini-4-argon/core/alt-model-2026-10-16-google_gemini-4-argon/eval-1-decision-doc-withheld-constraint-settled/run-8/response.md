I've updated `docs/intent/registry/registry-design.md` (and removed the open-backend note from `docs/high-level-design.md`) to finalize the local embedded SQLite index design. Because the HLD's offline-only tenets and non-goals already eliminate networked backends and the choice stays entirely inside the `registry` node without affecting `certificates`, I recorded this as a row in the LLD's **Decisions & Alternatives** table rather than a standalone decision doc.

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

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, local SQLite index preparation, and lookup all belong to this node. Each imported snapshot is indexed into an embedded SQLite database stored on the kiosk.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a staging SQLite database from the newline-delimited JSON records, storing normalized serial numbers (`TRIM` + uppercase ASCII) under a `UNIQUE` index alongside each record's calibration date, due date, and equipment description, and recording the snapshot metadata (`snapshotDate`, `schemaVersion`). Activate the new database by atomically swapping the active database pointer or file only after signature verification, schema check, and full index construction succeed. An import failure discards the staging database, leaves the previous snapshot active, and reports a useful error.

## Lookup Behavior

Normalize the requested serial number by trimming surrounding whitespace and uppercasing ASCII letters before querying the active SQLite database. Serial-number punctuation remains significant. Query the indexed normalized serial number and return `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Inherited HLD constraints forbid runtime network access and external services on isolated kiosks, eliminating networked backends; an embedded SQLite file built during snapshot import meets the 250 ms lookup target for 90,000 records entirely from local storage. |
```

### Phase 2 LLD-Level Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD above and let me know which of these component-internal edge cases you'd like to specify in the LLD now versus defer:

1. **Duplicate serial numbers after normalization**: Should uniqueness during snapshot import be enforced on the normalized serial number (e.g., `" ab-12 "` and `"AB-12"` collide and reject the snapshot) or only on the raw string? (The draft above assumes normalized uniqueness via the SQLite `UNIQUE` index.)
2. **Lookup before any snapshot is imported**: What happens when `findBySerial` is called on a fresh kiosk before the first valid snapshot has ever been imported (when no `snapshotDate` exists yet)?
3. **In-flight lookup during snapshot swap**: If a technician runs `findBySerial` at the exact moment a new SQLite database is being activated, how is the swap coordinated so the active query neither fails with a file/handle error nor mixes data across snapshots?
4. **Malformed JSON lines or missing record fields**: If a signed snapshot passes signature verification and schema version check, but a record line is malformed JSON or missing `calibrationDate`, `dueDate`, or `description`, should the entire import be rejected under the same atomic rollback guarantee?
5. **Older or same-date snapshot import (replay/downgrade)**: If a valid signed USB snapshot has a `snapshotDate` older than or equal to the currently active snapshot, should the registry reject it or allow replacing the active snapshot?
6. **Returned serial number format**: When `Found(record, snapshotDate)` is returned, does `record.serial` preserve the original casing from the snapshot JSON, or the normalized uppercase form?

Please let me know your feedback on the LLD draft and how you want to handle these probe items before we proceed to Phase 3.