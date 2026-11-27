Updated [`docs/intent/registry/registry-design.md`](docs/intent/registry/registry-design.md) with the SQLite design.

The backend decision is recorded in its **Decisions & Alternatives** table. A separate decision document isn’t warranted: the HLD’s offline-only constraint rules out both service-backed alternatives, and the choice belongs entirely to the registry.

## Registry LLD for review

### Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry serves approximately 90,000 records from snapshots up to 150 MB on kiosks with 4 GB of RAM. Lookups use kiosk-local files and target completion within 250 ms. Signed USB snapshots are the only update channel; the central inventory team owns record corrections.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite index construction, activation, and lookup all belong to the registry. Each kiosk builds its own embedded SQLite database when it imports a snapshot. SQLite runs within the kiosk application and requires no separate service.

### SQLite Storage

Each prepared snapshot has a separate SQLite database containing:

| Data | Purpose |
|---|---|
| Snapshot metadata | Schema version and snapshot date for the records in this database |
| Equipment records | Equipment serial number, description, calibration date, and due date |
| Unique normalized serial key | Exact-match lookup and detection of conflicting serial numbers |

Preserve the record’s serial number for display and derive a lookup key by trimming surrounding whitespace and uppercasing ASCII letters. Punctuation remains significant. Use the same key derivation for import and lookup; uniqueness applies to that key, so two records that normalize to the same key conflict.

Store the snapshot date with its database so lookup results cannot combine a record from one snapshot with the date from another. Use a parameterized equality query against the unique serial key. Populate the database incrementally from the snapshot rather than retaining the entire snapshot in memory. Lookup connections open the activated database read-only.

### Snapshot Import

1. Copy the snapshot package from approved USB media into a private staging area on the kiosk. Validation and index construction use this staged copy.
2. Verify the signature manifest and the signed snapshot content using the bundled public key. Reject unsupported schema versions.
3. Validate and stream records into a new staging database. Reject malformed records and duplicate normalized serial keys. Write snapshot metadata into the same database.
4. Commit the build transaction, close the writer, and verify database integrity before making the database eligible for activation.
5. Publish the completed database on kiosk-local storage, then atomically replace the active-snapshot reference. The reference identifies one complete database; staging files are never active lookup sources.

The published database and active-snapshot reference use the same local filesystem so publication can use atomic replacement. Complete database publication before switching the reference. An import failure leaves the previous active snapshot available and reports the failing stage with a useful error. Staging files can be discarded after failure without changing the active database.

### Activation and Lookup Consistency

A lookup pins one active database for the duration of its query and result construction. Activation directs new lookups to the replacement database while in-progress lookups finish against their pinned snapshot. Keep the previous database available until its readers finish.

After a restart, resolve the active-snapshot reference to its completed database. An interrupted build or an unpublished staging database is not eligible for lookup. Publication interrupted before the reference switches leaves the previous snapshot selected; a completed switch selects the replacement.

### Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup, then query the active SQLite database by exact normalized key. Return `Found(record, snapshotDate)` for a match and `NotFound(snapshotDate)` for a miss. Read the snapshot date from the same pinned database in both cases.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Kiosk-local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD requires lookups from kiosk-local files with no runtime network access. Service-backed lookups require connectivity unavailable during normal operation. SQLite provides indexed exact matches without a service; each kiosk accepts responsibility for validation and rebuilding its index on import. |
| Replacement preparation | Build a separate database and switch the active reference after validation | Rebuild the active database in place | Isolates import failures from the last valid snapshot and prevents partially imported records from becoming visible. |
| Serial-key uniqueness | Enforce uniqueness after lookup normalization | Enforce uniqueness only on the original serial text | Lookup normalization must identify at most one record; raw-text uniqueness alone permits ambiguous keys. |

### Open Questions & Future Decisions

The edge-case probe identified these questions, now recorded in the LLD:

1. What should happen before the first successful import, or when the active database is missing or corrupt? `NotFound(snapshotDate)` assumes an available snapshot; an unavailable registry needs an explicit failure contract.
2. Which whitespace characters count as surrounding whitespace, and how should empty serial numbers or invalid input be handled?
3. Should snapshot dates be required to advance, or may an operator intentionally activate an older signed snapshot?
4. How should concurrent import requests be handled, and how many inactive databases should remain after their readers finish?
5. What snapshot schema versions, field-validation rules, and signature-manifest format are supported?
6. What durability guarantee is required for activation if the kiosk loses power, rather than merely the application stopping?
7. Where is the import success boundary if activation succeeds but cleanup or reporting fails afterward, and what structured result represents each outcome?
8. What synchronization protects a lookup acquiring its database pin against simultaneous activation and retirement?
9. How is staged content kept immutable between signature verification and indexing, including the metadata used for the snapshot date?
10. How should SQLite read failures be reported, and does the 250 ms lookup target apply while an import competes for CPU and storage bandwidth?

### References

- [GaugeDesk high-level design](docs/high-level-design.md)
- [Registry specifications](docs/intent/registry/registry-specs.md)
- [Certificates design](docs/intent/certificates/certificates-design.md)

---

**Coherence check:** SQLite fits the HLD’s architecture and offline constraints. The HLD still describes the private backend as open; that summary needs synchronization once this design is approved. The existing registry specs cover the baseline behavior but need a subsequent update for the expanded design. `git diff --check` passed.

**Do you approve this LLD direction?** Please identify which numbered questions you want resolved now and which may remain deferred. In particular, confirm rejecting serial numbers that collide *after normalization*—for example, `abc-12` and ` ABC-12 `. I’ll pause here before the EARS phase.