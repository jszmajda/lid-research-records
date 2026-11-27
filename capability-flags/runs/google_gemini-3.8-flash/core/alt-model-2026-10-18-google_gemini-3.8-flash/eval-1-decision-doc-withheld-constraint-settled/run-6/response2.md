A standalone decision doc would be **overkill** for this choice. Under the earns-its-place heuristic:

1. **Inherited constraints settle it**: The HLD tenets already establish that kiosks operate air-gapped with no runtime network route, ruling out the HTTPS directory and managed search service.
2. **Node-local scope**: The decision affects only the private storage backend inside the registry; the `findBySerial` interface exposed to the certificates node remains identical.
3. **Landed obviousness**: A cold reader inspecting an offline kiosk application would find an embedded local SQLite index natural rather than contentious.

A row in the LLD's **Decisions & Alternatives** table is the appropriate level of record.

---

### Phase 2: Registry LLD Update

I have updated `docs/high-level-design.md` and `docs/intent/registry/registry-design.md` to specify the local embedded SQLite index, staging build, atomic replacement, and decisions table.

#### Current `docs/intent/registry/registry-design.md`:

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

Snapshot validation, index preparation, and queries are encapsulated within this node using an embedded SQLite database stored locally on the kiosk.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness.

When a valid snapshot is imported, build a new SQLite database in a staging location:
- Create the schema with an index on the normalized serial number.
- Ingest all snapshot records and store snapshot metadata (snapshot date and schema version).
- Verify database integrity before activation.

Once construction and integrity checks succeed, atomically replace the active database file so all new records become visible simultaneously without exposing a partial snapshot. If signature validation, schema checks, record uniqueness, or database preparation fails, abort import, remove staging files, retain the previously active database, and report an error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant.

Query the active SQLite index using the normalized serial number:
- If a match exists, return `Found(record, snapshotDate)`.
- If no match exists, return `NotFound(snapshotDate)`.

The active snapshot date is retrieved from the database metadata and returned in both cases.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend storage | Embedded SQLite index | On-site HTTPS directory, Managed search service | Satisfies the kiosk offline tenet with zero runtime network dependencies. Rebuilding the local index during snapshot import keeps query latency predictable (<250 ms) and requires no running background service. Networked alternatives violate the kiosk air-gap constraint. |

## Open Questions & Future Decisions

### Resolved
1. ✅ **Storage backend**: Embedded SQLite index on local disk, rebuilt on snapshot import.

### Deferred
1. SQLite PRAGMA configuration (e.g., WAL mode, synchronous settings) during snapshot import vs. query mode.
```

---

### LLD Edge-Case Probe (Internal Gaps)

1. **Initial kiosk state (zero snapshots)**: When a kiosk is first deployed before any snapshot has been imported, what should `findBySerial` return? Should it return `NotFound` with a sentinel/empty date, or raise an explicit `UninitializedRegistry` error that the UI/certificates component must handle?
2. **Disk exhaustion during staging**: If the kiosk runs out of storage space while building the staging SQLite index (given 150 MB snapshots and indexing overhead), does cleanup immediately purge the staging file and signal an explicit disk error?
3. **Concurrent lookup during atomic swap**: Does active database file replacement use an atomic file rename (or SQLite connection swap) that guarantees in-flight queries complete without file lock errors?

Please review the LLD changes and indicate how you'd like to triage the edge-case probe items before we proceed to Phase 3 (EARS specs).