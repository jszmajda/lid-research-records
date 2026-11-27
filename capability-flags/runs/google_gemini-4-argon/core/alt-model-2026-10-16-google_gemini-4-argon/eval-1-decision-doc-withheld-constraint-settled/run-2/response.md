I have updated `docs/intent/registry/registry-design.md` (and synchronized the one-line summary in `docs/high-level-design.md`) to finalize the local embedded SQLite index design. Because the HLD's offline-only kiosk tenets already eliminate network-dependent alternatives and the choice stays internal to `registry`, I recorded the backend selection as a row in the LLD's `Decisions & Alternatives` table rather than a standalone decision doc.

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

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The certificates node uses only this interface; SQLite file paths, schema details, and query syntax remain private to the registry component.

Snapshot validation, local SQLite index construction, and lookup all belong to this node. Each active snapshot is stored on the kiosk as an immutable SQLite database file indexed on the normalized serial number, with snapshot metadata (`snapshotDate`, `schemaVersion`) recorded in the database.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. During import, stream the newline-delimited JSON records into a staging SQLite file, normalizing each record's serial number (trimming surrounding whitespace and uppercasing ASCII letters) and enforcing a `UNIQUE` constraint on the normalized serial column. Build the serial-number index and commit the staging database before activation.

Activate the new snapshot only after signature verification, schema validation, record insertion, and index creation all succeed, by atomically switching the active database pointer to the completed SQLite file. An import failure discards the staging database, leaves the previous SQLite snapshot active, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active local SQLite database by exact match on the normalized serial index, reading the active `snapshotDate` from the same database so the returned record and snapshot date are always consistent. Return `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt per snapshot import | On-site HTTPS directory; managed search service | Keeps lookups local and predictable (<250 ms for 90,000 records on 4 GB RAM) with zero runtime services, matching the offline-only kiosk constraint (`docs/high-level-design.md` Tenets & Non-Goals) which rules out network-dependent directory or managed search options; accepts per-kiosk validation and index rebuild work during USB snapshot import. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review these internal gaps in `registry-design.md` and let me know which ones to resolve in the LLD now versus defer to `Open Questions & Future Decisions`:

1. **Cold start / missing snapshot on lookup:** What happens when `findBySerial(serial)` is called before any snapshot has ever been imported (or if the active SQLite file is missing/corrupt), given that `Found(record, snapshotDate)` and `NotFound(snapshotDate)` both require a `snapshotDate`?
2. **Duplicate collision after normalization & malformed records:** When two records have distinct raw serials that collide after normalization (e.g., `"sn-100"` and `" SN-100 "`), or a record has an empty/whitespace-only serial or missing fields, should that abort the whole import under the same rejection path, and what error shape should the import entrypoint return?
3. **Concurrent lookup during snapshot activation & old snapshot cleanup:** How is the active database pointer represented (e.g., atomic file rename, symlink, or pointer file + connection swap), and how are in-flight lookups protected when switching snapshots and cleaning up the superseded SQLite file?
4. **Snapshot date ordering (rollback / re-import):** What happens when a validly signed snapshot has a `snapshotDate` older than or equal to the currently active snapshot — should the registry reject older snapshots or allow any validly signed snapshot?
5. **Interrupted import cleanup:** What happens on startup or next import if a power loss mid-import left an orphaned staging SQLite file on disk?
6. **Returned serial format & empty lookup strings:** In `Found(record, snapshotDate)`, should `record.serial` contain the normalized serial or the raw serial as written in the snapshot, and should an empty/whitespace-only query string simply return `NotFound(snapshotDate)`?

How would you like to triage these items, and does the updated LLD look good to proceed to Phase 3?