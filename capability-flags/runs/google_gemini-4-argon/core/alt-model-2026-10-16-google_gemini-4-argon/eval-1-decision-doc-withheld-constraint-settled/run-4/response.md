I updated `docs/intent/registry/registry-design.md` (and removed the open-backend note in `docs/high-level-design.md`) to finalize the local embedded SQLite index design.

Because kiosks have no runtime network access per the HLD tenets and the choice stays entirely inside the registry component without affecting `certificates`, a row in the `Decisions & Alternatives` table settles why SQLite was chosen without needing a separate decision doc.

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

Snapshot validation, SQLite index construction, and lookup all belong to this node. The active registry state is backed by a local embedded SQLite database on the kiosk filesystem, containing a records table indexed by normalized serial number and a metadata table storing the snapshot date and schema version.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the SQLite database in a staging file on the same filesystem as the active database, inserting normalized serial numbers with a `UNIQUE` index constraint and recording the snapshot metadata. Activate the new snapshot by atomically replacing the active SQLite file only after all records are indexed and verified. An import failure removes the staging file, leaves the previous SQLite database active, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite database by normalized serial number and read the snapshot date from the database metadata so every lookup result (`Found` or `NotFound`) carries a consistent snapshot date.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Keeps lookups predictable (~90k records within 250 ms on 4 GB RAM) with no runtime service or network dependency, satisfying the HLD offline-kiosk constraints while confining snapshot indexing to the registry component. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD above and let me know which of these component-level edge cases we should specify in the LLD vs. defer as open questions:

1. **Duplicate serial numbers after normalization**: Should uniqueness validation during snapshot import check raw serial strings or normalized serial strings (trimmed + uppercase ASCII), e.g. `" ab-1 "` and `"AB-1"` in the same snapshot?
2. **Lookup before any snapshot is imported**: What should `findBySerial(serial)` return on a freshly deployed kiosk before an initial USB snapshot has been imported (or is a seed snapshot bundled at installation)?
3. **In-flight lookups during snapshot swap**: When a replacement SQLite file is activated while a lookup is in progress, should each `findBySerial` call open a short-lived read-only connection per query or swap a pooled connection handle after active reads finish?
4. **Malformed JSON lines or missing record fields**: Should a single malformed JSON line or record missing `serial`, `description`, `calibrationDate`, or `dueDate` fail the entire snapshot import and retain the active snapshot?
5. **Older snapshot date import (rollback)**: Should the registry allow activating a validly signed snapshot whose `snapshotDate` is older than the currently active snapshot, or reject/warn on older snapshots?

How does the updated LLD look, and how would you like to triage items 1–5 before we proceed to Phase 3?