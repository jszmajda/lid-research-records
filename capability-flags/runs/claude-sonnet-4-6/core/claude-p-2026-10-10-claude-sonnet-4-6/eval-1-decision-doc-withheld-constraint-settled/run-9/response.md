LLD is written. Now let me run the LLD-level edge-case probe before presenting the stop.

**Edge-case probe — "what happens when..."**

These are gaps I found pointed at *this LLD's own mechanisms*:

1. **Corrupted active index at runtime.** The atomic-rename path prevents a partially written file from becoming active during import. But if the file is corrupted by other means (power loss after rename, disk error), `findBySerial` has no specified behavior — the LLD is silent on whether it returns an error, falls back to "no snapshot," or panics.

2. **Serial that normalizes to empty string.** A record whose serial field is all whitespace normalizes to `""`. The LLD says uniqueness is checked on the normalized form, so two such records would collide and the import would be rejected — but a single such record would pass and become a lookup key of `""`. Should the import reject records whose normalized serial is empty?

3. **Import error reporting interface.** The LLD says a failed import "reports a useful error," but the interface by which that error surfaces is unspecified. `findBySerial` is defined (return types: `Found`, `NotFound`, or error). What does the import call return? Does the caller get an error value, or does the component emit an event?

4. **Active index file location.** The LLD says the temp file sits "alongside" the active index but doesn't say where the active index lives (configurable path, fixed kiosk path, etc.). This is probably an implementation detail, but worth confirming it belongs here or in the certificates/host layer.

---

**Phase 2 stop — draft LLD for your review.**

Here is the updated registry design:

---

```
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date,
and equipment description. A signed snapshot contains newline-delimited JSON records,
a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or
`NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates
node uses only this interface.

Snapshot validation, index rebuild, and lookup all belong to this node. The lookup
backend is a local embedded SQLite database, rebuilt from each incoming snapshot.
No network access is required at any point.

## SQLite Index

The active index is a single SQLite database file on the kiosk's local filesystem.
It contains two tables:

  equipment(serial_norm TEXT PRIMARY KEY, serial_orig TEXT, description TEXT,
            calibration_date TEXT, due_date TEXT)
  snapshot_meta(snapshot_date TEXT)

serial_norm is the normalized form: surrounding whitespace stripped and ASCII letters
uppercased; punctuation preserved. This is the query key. serial_orig preserves the
raw value for display and audit purposes.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions,
and check that no two records share a normalized serial number. Write all validated
records into a new SQLite file at a temporary path. Do not alter the active index file
during this phase. Once fully written and all validations have passed, rename the
temporary file to the active index path; the rename is atomic at the OS level. An
import failure at any stage leaves the previous active index in place and reports a
useful error. The temporary file is removed on failure.

## Lookup Behavior

Normalize the query input (strip surrounding whitespace, uppercase ASCII letters,
preserve punctuation), then execute a primary-key lookup against equipment.serial_norm.
Return Found(record, snapshotDate) on a match or NotFound(snapshotDate) when absent.
The snapshot date is read from snapshot_meta and cached; the cache is invalidated and
reloaded when a new snapshot is activated.

While no snapshot has ever been imported, findBySerial returns an error indicating
no snapshot is available; it does not return NotFound with a missing date.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite | On-site HTTPS directory; managed search service | SQLite requires no network access (the HLD prohibits runtime network access), no credentials, and no external service. Primary-key lookup over 90 k records comfortably meets the 250 ms goal. The HTTPS directory depends on lab network availability and requires service-timeout handling. The managed search service adds recurring cost, credentials, and external connectivity as registry concerns. |
| Atomic activation | Write to temp path, then rename | Write in-place; retain two versioned files | An OS-level rename is atomic on all target platforms, preventing any partially written index from becoming active with no extra bookkeeping. |
| Normalization timing | At import, stored as serial_norm | Normalize at query time per lookup | One pass at import makes every lookup a direct primary-key read. |
| Uniqueness check domain | Normalized serial | Original serial only | The index primary key is the normalized serial; a collision on normalized form would silently overwrite a record. Checking normalized form is the correct semantic for lookup identity. |
| Snapshot date caching | Cache invalidated on new import | Read from DB on every lookup; cache for session with no invalidation | Re-reading on every lookup adds a second query to every call. Holding a stale date would expose a window where the returned date contradicts the records. |

## Open Questions & Future Decisions

### Deferred
1. Whether to retain the previous active index file as a rollback artifact after
   successful activation — depends on storage budget and whether operators need
   a one-step rollback path.
```

---

**Three gaps from the edge-case probe — please triage:**

**Gap A — corrupted active index at runtime.** If the index file exists but is unreadable (disk error, power loss after rename), what should `findBySerial` return? Options: (a) return an error distinct from "no snapshot," (b) treat it the same as "no snapshot available," (c) attempt to detect corruption at startup and halt. Which behavior do you want?

**Gap B — serial that normalizes to empty string.** An all-whitespace serial in a snapshot survives uniqueness checks and becomes a lookup key of `""`. Should the import reject any record whose normalized serial is empty?

**Gap C — import error reporting interface.** The LLD says "reports a useful error" but doesn't say how — return value, exception, event, etc. Is this detail for the LLD, or should it stay unspecified here and appear in the implementation?

Once you've reviewed and given feedback on A, B, and C, I'll incorporate your answers and we'll move to Phase 3 (EARS specs).