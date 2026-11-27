I have updated `docs/high-level-design.md` and `docs/intent/registry/registry-design.md` for **Phase 2 (LLD)** to reflect the local embedded SQLite index selection and recorded the choice in `Decisions & Alternatives` (an inherited HLD constraint — offline-only lookups from local files with signed USB updates as the sole channel — eliminates the network-backed options and the choice is confined to the registry segment, so a table row suffices without a standalone decision doc).

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

Snapshot validation, local SQLite index construction, and lookup all belong to this node. Each kiosk stores the active snapshot metadata and its embedded SQLite database on local disk.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build a fresh local SQLite database file in a staging path from the snapshot's newline-delimited JSON records, normalizing each serial number as the primary key and storing the snapshot metadata alongside the records. Activate the new SQLite database atomically only after signature verification, schema check, uniqueness validation, and index construction all succeed. An import failure removes the staged database, leaves the previous active SQLite database untouched, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before querying the active SQLite database by primary key. Serial-number punctuation remains significant. Return the active snapshot date alongside the matching record, or with `NotFound` when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | HLD tenets require all serial-number lookups to complete using files on the kiosk with no runtime network access and signed USB snapshots as the only update channel, eliminating network-dependent backends. A local SQLite primary-key index meets the 250 ms lookup goal for 90,000 records within 4 GB RAM without running a local service. |
```

*(Also updated the Registry bullet in `docs/high-level-design.md` to remove "Its private lookup backend remains open.")*

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please let me know which of these registry LLD gaps you want to specify in the design now versus defer as open questions:

1. **No active snapshot at startup (cold start):** What happens when `findBySerial(serial)` is called on a freshly provisioned kiosk before any valid snapshot has been imported (when no `snapshotDate` exists yet)?
2. **Duplicate serial numbers after normalization:** Does uniqueness validation during snapshot import compare raw serial strings as written in the NDJSON, or normalized serial numbers (trimmed whitespace, uppercased ASCII) so two records like `"ab-1"` and `"AB-1 "` are caught as duplicates?
3. **In-flight lookups during snapshot activation:** When a replacement SQLite file is activated while a lookup is in progress, how is the cutover handled (e.g., atomic filesystem rename or pointer file swap with read-only connections per query, vs. connection reopen)?
4. **Malformed NDJSON records or missing required fields:** If a properly signed snapshot with a supported schema version contains a corrupted JSON line or a record missing `serial`, `description`, `calibrationDate`, or `dueDate`, should the entire import fail and roll back identically to a signature/duplicate error?
5. **Import error shape and interface:** What is the entry-point signature and error structure for snapshot import (e.g., `importSnapshot(path)` returning specific error categories for signature failure, schema mismatch, duplicate serial, malformed record, or disk I/O failure)?
6. **Corrupted active SQLite file on disk:** What happens if the active local SQLite database file is unreadable or fails integrity checks at query time?

How does the updated LLD look, and how would you like to triage items 1–6?