## Phase 2 Review

The SQLite choice is recorded in `docs/intent/registry/registry-design.md`. I also removed the stale “backend remains open” wording from `docs/high-level-design.md`.

The two network-backed alternatives were not equivalent under the existing HLD: both conflict with the requirements for kiosk-local lookup, no runtime network route, and USB-only registry updates. SQLite is the only listed option consistent with those constraints, so the rationale is captured in the LLD’s decision table rather than a separate decision document.

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

Snapshot validation, index preparation, activation, and lookup all belong to this node. Each kiosk keeps an embedded SQLite index in application-owned local storage. SQLite is an implementation detail behind the registry interface; certificates do not receive database handles, paths, query syntax, or index lifecycle state.

The registry keeps each prepared snapshot in its own immutable database file. A small active-snapshot marker identifies the database used for new lookups. Keeping database files versioned separates preparation from activation and avoids replacing a file while lookups still hold it open.

## Snapshot Import

Import proceeds in an application-owned staging area on the same local filesystem as the active index:

1. Copy the snapshot from approved media into staging so later media removal cannot change the import input.
2. Verify the signature manifest with the bundled public key before trusting snapshot metadata or records.
3. Reject unsupported schema versions, malformed records, and duplicate serial-number keys.
4. Build a new SQLite database containing the snapshot date, schema version, source digest, and equipment records. Create a unique index over the normalized serial-number key and run SQLite's integrity check.
5. Close the prepared database, move it to its immutable final path, and atomically replace the active-snapshot marker.

The active marker is the commit point. Until it is replaced, concurrent lookups continue to use the previous database. After replacement, new lookups use the new database; in-flight lookups may finish against the database they acquired. The registry retains an old database until no lookup holds it and removes abandoned staging artifacts during a later startup or import.

Any failure before the commit point leaves the active marker unchanged and reports the import stage and cause without exposing records from the rejected snapshot. On startup, the registry ignores prepared databases that are not named by the active marker.

## SQLite Data Model

The database contains two logical tables:

| Table | Contents | Constraints |
|---|---|---|
| `snapshot` | One row with snapshot date, schema version, and source digest | Exactly one row |
| `equipment` | Normalized serial key, source serial number, equipment description, calibration date, and due date | Normalized serial key is unique |

All values are bound as parameters. Snapshot content never becomes SQL text. The registry opens an activated database read-only for lookup and does not mutate inventory records in place.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before querying the unique serial-key index. Serial-number punctuation remains significant. Return `Found(record, snapshotDate)` for the exact normalized key or `NotFound(snapshotDate)` when it is absent. The snapshot date comes from the same database as the equipment result so a lookup cannot combine record data and metadata from different snapshots.

The registry owns connection reuse and active-database handoff. `findBySerial` neither waits for an import to finish nor queries staged databases; it acquires the currently active database for the duration of one lookup.

## Failure and Recovery Boundaries

- A rejected or interrupted import does not alter the active marker.
- A database absent from the active marker is never eligible for lookup, even if its build completed.
- An active marker that cannot be read or points to an unreadable database is a registry-unavailable condition rather than an empty registry.
- SQLite and filesystem failures are reported by registry operation and are not translated into `NotFound`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Embedded SQLite index maintained independently by each kiosk | On-site HTTPS directory; managed search service | SQLite satisfies the kiosk-local lookup and USB-only update constraints without service availability, network timeout, credential, or recurring-cost concerns. Per-kiosk validation and index rebuilding remain contained within the registry boundary. |
| Snapshot activation | Immutable versioned database plus atomically replaced active marker | Replace one fixed database file; update an active database in place | A separate commit point keeps partial builds invisible, preserves the prior snapshot on failure, and permits in-flight readers to finish without exposing mixed snapshots. |

## Open Questions & Future Decisions

### Resolved

1. Use a local embedded SQLite index while preserving the registry result interface.

### Deferred

1. Define the technician-visible state and recovery action when a kiosk has no valid active snapshot.
2. Decide whether a snapshot whose date is older than the active snapshot may be activated intentionally.
3. Define whether serial-number uniqueness is evaluated before or after lookup normalization.
```

The edge-case probe found no direct HLD contradiction, but these gaps need triage:

1. What happens when two imports run concurrently?
2. What durability guarantee applies if power fails while the active marker is being replaced?
3. What concrete result does `findBySerial` return when no usable registry exists? Adding an unavailable result would affect the certificates segment, so I will not propagate that interface change without confirmation.
4. Should post-activation corruption leave the registry unavailable or fall back to the previous valid snapshot?
5. Should serial numbers that differ in source text but normalize to the same lookup key cause snapshot rejection?
6. May technicians intentionally install an older snapshot?
7. How should retrying an already-prepared snapshot behave?
8. Which SQLite transaction, journaling, and read-only settings guarantee that sidecar files cannot undermine immutability?
9. Which invalid lookup inputs produce an error rather than `NotFound`?
10. Can cleanup failures accumulate old databases without blocking successful activation, and what storage bound applies?

Please approve the Phase 2 design or reply with numbered feedback, including which probe items should be resolved now versus explicitly deferred. I’ll then draft the registry EARS updates.