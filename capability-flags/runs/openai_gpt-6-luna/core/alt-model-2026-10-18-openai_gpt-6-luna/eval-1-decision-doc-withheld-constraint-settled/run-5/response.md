The HLD’s offline constraints support the local SQLite choice. I updated its registry summary and drafted the registry LLD; the certificate component’s interface remains unchanged.

### Registry LLD draft

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, equipment description, and the date of the registry snapshot used. The central inventory team supplies signed snapshots on approved USB media; kiosks have no runtime network access. A snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Registry data is read-only on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are independent of the storage schema. The certificates component uses only this interface and does not access the SQLite database or its path.

The registry uses a local SQLite database as a derived, indexed representation of the active signed snapshot. SQLite is embedded with the kiosk application; registry lookup requires no service process or network connection. The signed snapshot remains the input to import and validation; SQLite is not an independently editable source of inventory data.

Snapshot validation, candidate-index construction, activation, and lookup all belong to this node. The index uses a canonical serial-number key and a database index to resolve lookups without scanning all records. The active snapshot date is stored with the indexed snapshot so it accompanies both found and not-found results.

The index must support approximately 90,000 records, snapshots up to 150 MB, and the HLD lookup target of 250 ms on a kiosk with 4 GB of RAM. Candidate construction must leave the active index available until activation succeeds.

## Snapshot Import

Verify the signature using a bundled public key and reject unsupported schema versions before activating any records. Read and validate every record while building an inactive candidate snapshot in SQLite. Enforce serial-key uniqueness within that candidate and verify that the candidate index is complete before activation. A single SQLite transaction switches the active snapshot to the candidate and removes the prior active data, so registry queries observe the old complete snapshot or the new complete snapshot, never a partial mixture. If validation, candidate construction, or activation fails, keep the previous active snapshot and report a useful import error. Incomplete inactive candidate data is not eligible for lookup and can be discarded during import cleanup.

The database records the snapshot date alongside the snapshot identity. Lookup obtains the record and snapshot date from the same active snapshot, preventing metadata from one import from being paired with records from another.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Use the normalized serial key in the SQLite lookup; retain the record's source fields for the returned registry record. Return the active snapshot date for both `Found` and `NotFound` results. A storage or database failure must not be reported as `NotFound`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup index | A local embedded SQLite index, built and validated by each kiosk when a signed snapshot arrives | An on-site HTTPS directory; a managed search service | Kiosks have no runtime network route and all lookup must use kiosk-local files. SQLite provides indexed local lookup without a service process and keeps storage and import concerns inside the registry while preserving the certificate-facing result contract. |
| Snapshot activation | Activate a fully built candidate through one SQLite transaction | Update active records incrementally; replace the active database before validation completes | A transaction boundary makes the active snapshot all-or-nothing and preserves the prior snapshot if candidate validation or activation fails. |

## Open Questions & Future Decisions

### Resolved

1. The registry lookup backend is a local SQLite index; the certificate interface remains unchanged.

### Deferred

1. Define the lookup result/error contract when no snapshot is active or the SQLite database is unavailable or corrupt.
2. Decide whether the kiosk retains a validated source snapshot for rebuilding a damaged index, or requires the operator to re-import USB media.
3. Define the exact whitespace character set used when normalizing serial numbers; this also determines which source serials collide on the unique lookup key.
4. Define the snapshot record schema's malformed-record behavior and whether empty snapshots are valid.
5. Define the minimum free disk space required to stage a candidate index while the current index remains active.

## References

- `docs/high-level-design.md` — offline operating constraints and lookup goals.
- `docs/intent/registry/registry-specs.md` — registry behavior requirements.
```

The selected SQLite approach is recorded in the registry LLD’s Decisions & Alternatives table. The network-based alternatives conflict with the HLD’s offline constraint, so a separate decision document does not appear necessary.

### LLD edge-case probe — please triage

1. **No active snapshot or database failure:** Should lookup return a distinct registry error, or report failure through an exception/operation-level error? It must not look like `NotFound`. A distinct result may affect the certificate segment, so I’ll pause before changing that interface.
2. **Index recovery:** Should each kiosk retain the validated source snapshot for rebuilding a damaged index, or should recovery require re-importing the USB snapshot?
3. **Serial normalization:** Which whitespace characters count as surrounding whitespace? This also determines whether serials differing only by that whitespace collide on the unique lookup key.
4. **Malformed and empty snapshots:** Should any malformed record reject the entire snapshot, and is a valid snapshot allowed to contain zero records?
5. **Staging disk space:** Should the design set a minimum free-space requirement for building a candidate index while keeping the active index available, or defer that limit?

### Coherence check

- **HLD → registry LLD:** Consistent. The local index fits the kiosk-local, no-runtime-network architecture and leaves snapshot validation and lookup in the registry.
- **Registry LLD → existing REG specs:** The existing specs cover normalization, snapshot dates, validation, and all-at-once activation. They do not yet capture the SQLite implementation or resolve the open error and recovery behavior; I’ll update the specs after this design review.
- **Registry LLD → certificates:** Consistent so far. Certificates continue to consume the fixed registry result contract and do not access registry storage.
- `git diff --check` passes.

Please review the LLD and decide which probe items to resolve now versus defer. I’ll stop here for the Phase 2 review.