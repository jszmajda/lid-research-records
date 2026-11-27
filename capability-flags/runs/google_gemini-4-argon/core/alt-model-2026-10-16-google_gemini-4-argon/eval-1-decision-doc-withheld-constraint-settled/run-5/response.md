I updated `docs/intent/registry/registry-design.md` (and removed the open-backend note from `docs/high-level-design.md`) to finalize the local embedded SQLite index design. Because the HLD already prohibits runtime network access on kiosks and the backend is encapsulated inside `registry`, I recorded the choice as a row in the LLD's `Decisions & Alternatives` table rather than creating a standalone decision doc.

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

Snapshot validation, local embedded SQLite index preparation, and lookup all belong to this node. Each kiosk stores the active snapshot inside a local SQLite database file containing a `records` table indexed by normalized serial number (`serial_normalized`, `serial`, `description`, `calibration_date`, `due_date`) and a `metadata` table holding the active `snapshot_date` and `schema_version`.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the SQLite database for the incoming snapshot in a staging file on the same local filesystem so partially imported records are never exposed to concurrent lookups. Once signature verification, schema validation, uniqueness enforcement (on normalized serial numbers), and index construction succeed, atomically replace the active SQLite database file with the staged file. An import failure deletes the staging file, leaves the previous snapshot active, and reports a descriptive error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite index by the normalized serial number and read the snapshot date from the same database snapshot. Return `Found(record, snapshotDate)` when a row matches and `NotFound(snapshotDate)` when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Keeps lookups predictable within the 250 ms budget on 4 GB RAM without any network dependency; the HLD prohibits runtime network access on isolated kiosks, ruling out network-backed services despite each kiosk rebuilding its own index on snapshot import. |
```

### Phase 2 LLD-Level Edge-Case Probe

Before moving to Phase 3 (EARS specs), please let me know which of these LLD-level edge cases you want to specify in the design now versus defer as open questions:

1. **Duplicate detection normalization**: Should duplicate serial numbers during snapshot import be checked after applying the same normalization used at lookup (`trim` + uppercase ASCII), so e.g. `"ab-1"` and `" AB-1 "` collide on import, or only on raw string equality? (The draft currently assumes normalized uniqueness.)
2. **Initial unseeded state**: What happens when `findBySerial(serial)` is called on a freshly provisioned kiosk before any snapshot has ever been imported (when no active `snapshotDate` exists)?
3. **Concurrent lookup during activation**: When a new SQLite file replaces the active one while a lookup is in flight, should the registry re-open/swap a connection handle per query, or maintain a persistent connection swap lock so Windows/Linux file replacement semantics don't fail or read stale handles?
4. **Malformed JSON lines / missing required fields**: If a single record in the NDJSON stream is malformed JSON or missing `serial`, `description`, `calibration_date`, or `due_date`, should the entire snapshot import fail and roll back identically to a schema/duplicate error?
5. **Disk space or SQLite write failure during staging**: If building the staging SQLite file fails mid-import (e.g., disk full on a 150 MB snapshot), should the error shape distinguish storage/IO errors from snapshot validation errors (`InvalidSignature`, `UnsupportedSchema`, `DuplicateSerial`)?

How does the updated LLD look, and how would you like to triage the edge cases above before we proceed to Phase 3 (EARS specs)?