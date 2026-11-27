**Phase 2: Registry Design**

`docs/intent/registry/registry-design.md` now contains:

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

Snapshot validation, index preparation, activation, recovery, and lookup all belong to this node. Each kiosk uses an embedded SQLite database that requires no separately managed process and makes no network request. The database and its filesystem layout are private to the registry.

## Snapshot Import

Treat each import as a new immutable generation. Verify the signature manifest with the bundled public key and reject unsupported schema versions before accepting records. Normalize each serial number with the same function used by lookup and reject duplicate normalized serial numbers.

Build the generation in a staging location rather than modifying the active database. In one SQLite transaction, insert the records into a table keyed by the normalized serial number and write the snapshot date, schema version, and signed snapshot identity into metadata. Use SQLite's binary text comparison for the normalized key so punctuation remains significant. Commit and close the database, then run an integrity check and verify the stored record count before the generation is eligible for activation.

Activate an eligible generation by atomically replacing a small active-generation pointer under a registry process lock. The database file itself is never replaced in place. A lookup that has already acquired a generation may finish against it; lookups that begin after activation use the new generation. Retain the preceding generation until no lookup holds it, then remove it. Any validation, build, integrity-check, or activation failure removes only the staging generation, leaves the active pointer unchanged, and reports the failed stage without exposing snapshot record contents.

On startup, resolve and validate the active-generation pointer before serving lookups. Ignore and remove abandoned staging generations. If the pointer cannot be resolved to an integrity-checked database, report the registry as unavailable rather than selecting a generation by directory order or rebuilding from unverified files.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Acquire the active immutable generation, execute an equality query on its normalized primary key, and release that generation after materializing the result. Return the generation's snapshot date from metadata whether the result is `Found` or `NotFound`.

SQLite connection management is internal to the registry. Connections are read-only after generation activation, use bound query parameters, and have a finite busy timeout so a storage fault cannot leave a lookup waiting indefinitely. Because imports never write the active database, lock contention is not part of normal lookup or import behavior.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Embedded SQLite index on every kiosk | On-site HTTPS directory; managed search service | Local lookup preserves operation without a network route and avoids a separately operated service. It accepts per-kiosk validation and index-build work when a signed snapshot arrives. |
| Snapshot publication | Immutable database generations selected by an atomic pointer | Replace the active database file in place; mutate one database | Generation switching prevents failed or interrupted imports from changing the active snapshot and lets in-flight lookups finish against one coherent generation. |
| Serial-number key | Application-normalized text primary key with binary comparison | SQLite case-insensitive collation; scan snapshot records | One normalization path makes import-time uniqueness and lookup matching agree while retaining punctuation significance. |

## Open Questions & Future Decisions

### Deferred

1. Set storage-space limits and retention behavior if kiosk disk capacity becomes constrained beyond the active and immediately preceding generations.
```

The LLD edge-case probe found these gaps for your triage:

1. What should `findBySerial` return before the first snapshot is active, while the registry is unavailable, or after a SQLite I/O, corruption, or timeout error? Its current result type only permits `Found` and `NotFound`.
2. Which durability guarantees must the pointer and database writes provide if power fails during activation?
3. How should lookup acquisition and generation retirement synchronize so cleanup cannot remove a generation between reading the pointer and establishing a hold?
4. Should every generation still held by a lookup be retained, rather than only the immediately preceding generation?
5. Should imports be serialized, and if multiple imports arrive, which one wins?
6. Should older, same-date, or previously imported snapshots be accepted?
7. Which malformed or missing record fields and date values must snapshot validation reject?
8. Which manifest fields are signed, and what authoritative count should the built database be checked against?
9. Is enforcement of “approved USB media” owned by the registry, or by a component outside this design?
10. How should empty, whitespace-only, control-character, or non-ASCII serial inputs behave?
11. What result should occur if lookup cannot meet the 250 ms goal?
12. How should failed cleanup of staging or retired generations be recovered?

Please approve the LLD and mark these questions as `fix` or `defer` by number, with any desired answers for those to fix.