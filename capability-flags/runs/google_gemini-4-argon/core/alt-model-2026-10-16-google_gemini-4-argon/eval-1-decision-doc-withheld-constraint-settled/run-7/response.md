I have updated `docs/intent/registry/registry-design.md` (and removed the open-backend note in `docs/high-level-design.md`) to incorporate the local embedded SQLite index and recorded the selection in the LLD's `Decisions & Alternatives` table (as the offline kiosk tenet and internal encapsulation settle the choice cleanly without needing a standalone decision doc).

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

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of internal storage details. The certificates node uses only this interface.

Snapshot validation, local embedded SQLite index preparation, and lookup all belong to this node. Each kiosk maintains its own embedded SQLite index built from the active signed snapshot.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a fresh SQLite database file in a staging path from the snapshot's newline-delimited JSON records, enforce a unique index on normalized serial numbers, and store snapshot metadata (schema version and snapshot date) alongside the records. Activate the new snapshot only after signature verification, record validation, and index creation succeed by atomically swapping the staged SQLite file into the active index path. An import failure discards the staged database, leaves the previous SQLite index active, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active embedded SQLite index by the normalized serial number and read the snapshot date from the active database's metadata. Return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Kiosks operate without runtime network access (`docs/high-level-design.md` Tenets and Non-Goals), ruling out network-dependent directory and cloud search services; an embedded SQLite index meets the 250 ms lookup target for 90,000 records on 4 GB RAM with zero external services, keeping snapshot validation and index rebuild encapsulated inside the registry component. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please triage which of these LLD-level edge cases you want specified in `registry-design.md` now versus deferred to `Open Questions & Future Decisions`:

1. **Duplicate serial numbers after normalization:** When checking uniqueness during snapshot import, are serial numbers compared *after* normalizing whitespace and ASCII case (e.g., `" ab-12 "` and `"AB-12"` collide and fail the import), or on raw string values?
2. **Cold-start state (no snapshot imported yet):** What happens when `findBySerial(serial)` is called on a fresh kiosk before any valid snapshot has ever been imported (where no `snapshotDate` exists yet)?
3. **Concurrent lookup and activation:** What happens when a `findBySerial(serial)` query is in flight at the exact moment a newly built SQLite file is swapped into the active path (e.g., open a read-only connection per lookup vs. coordinate connection swap across readers)?
4. **Malformed or incomplete JSON records:** How should snapshot import handle a record line that is syntactically invalid JSON or missing required fields (`serial`, `description`, `calibrationDate`, `dueDate`) — reject the entire snapshot on the first bad line, or collect validation errors?
5. **Interrupted staging cleanup & disk space:** If a previous import crashed mid-build leaving a stale staging `.sqlite` file on disk, or if disk space runs out while building the index from a 150 MB snapshot, how should the importer recover and report the failure?
6. **Import error shape:** Does the snapshot import entry point need a defined return/error structure (e.g., distinct error codes for `InvalidSignature`, `UnsupportedSchema`, `DuplicateSerial`, `MalformedRecord`) for the caller to display?

How does the updated LLD look, and which of items 1–6 would you like folded into the design vs. deferred before we proceed to Phase 3?