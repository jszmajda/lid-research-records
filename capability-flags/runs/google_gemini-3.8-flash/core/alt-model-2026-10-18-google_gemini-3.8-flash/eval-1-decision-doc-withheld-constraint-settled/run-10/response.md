The registry low-level design (`docs/intent/registry/registry-design.md`) has been updated to incorporate the local embedded SQLite index.

### Updated Low-Level Design

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the internal storage representation. The certificates node uses only this interface.

Snapshot validation, SQLite index construction, and query execution all belong to this node. The registry maintains a local embedded SQLite database populated from the active snapshot, ensuring completely offline, sub-second lookups without network dependencies or external daemon processes.

## Snapshot Import & Indexing

1. **Validation**: Verify the snapshot signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness across the snapshot.
2. **Staging Index Construction**: Ingest the newline-delimited JSON records into a new staging SQLite database file. Populate a table holding the normalized serial number, raw serial number, equipment description, calibration date, and due date, indexing the normalized serial number for fast point lookups. Store the snapshot date and metadata in a dedicated table.
3. **Atomic Activation**: Once the staging SQLite database is successfully constructed and validated, atomically promote it to the active database path. Any active read-only connection is swapped or re-opened against the newly activated database.
4. **Failure Handling**: If signature verification, schema validation, serial uniqueness checks, or SQLite construction fails at any stage, abort the import, remove any intermediate staging files, and keep the existing active database intact. Return an informative error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant (e.g., hyphens and slashes are preserved). Lookups query the active SQLite index using the normalized serial number. Return `Found(record, snapshotDate)` if a matching record exists, or `NotFound(snapshotDate)` if no record matches. Return the active snapshot date on both found and not found results. Lookups operate in read-only mode against the active SQLite database.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, managed search service | Predictable sub-millisecond query performance on offline kiosks with no runtime network dependencies or background services; keeps snapshot validation and index rebuild fully encapsulated within the registry component while satisfying kiosk isolation tenets. |
```

---

### LLD-Level Edge-Case Probe

The following gaps and edge-case questions were identified inside the component:

1. **Cold-Start / Uninitialized State**: What does `findBySerial` return when called before any snapshot has ever been imported into the kiosk (given that `NotFound` requires a `snapshotDate`)?
2. **Normalized vs. Raw Uniqueness**: What happens if two records in a snapshot have distinct raw serial numbers that collide after normalization (e.g., `sn-01` vs. `SN-01`, or differing whitespace)?
3. **Snapshot Date Ordering / Monotonicity**: What happens if an import is attempted with a validly signed snapshot that is older than the currently active snapshot (is rollback permitted or rejected)?
4. **Import Entrypoint & Error Contract**: What is the explicit import API signature, and what structured error shapes/categories are returned when import or validation fails?
5. **In-Flight Query Concurrency During Promotion**: What happens to active read queries at the moment the staging database is promoted to active and connections are swapped?
6. **Active Database Integrity at Boot**: What happens if the active SQLite database file is corrupt or truncated on kiosk startup (e.g., following an abrupt power loss)?
7. **Disk Space Exhaustion**: What happens if storage is exhausted mid-staging when unpacking and indexing a 150 MB snapshot?
8. **Concurrent Import Requests**: What happens if a snapshot import is triggered while a prior import/build is already in progress?

---

Please indicate which of these edge cases you would like incorporated into the LLD vs. deferred as open questions, and confirm if you are ready to proceed to Phase 3 (EARS spec updates).