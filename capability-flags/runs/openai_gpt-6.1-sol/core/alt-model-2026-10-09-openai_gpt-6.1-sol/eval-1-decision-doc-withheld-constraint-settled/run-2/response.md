Updated `docs/intent/registry/registry-design.md` with the SQLite design draft. The backend choice is recorded in its Decisions & Alternatives table: the HLD’s offline-only constraint rules out both network-dependent alternatives, so a separate decision document isn’t needed.

The design is below for review. `git diff --check` passes.

## Registry Design

**Parent:** high-level-design  
**Spec prefix:** REG

### Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry serves approximately 90,000 serial numbers on kiosks with 4 GB of RAM. Snapshots can reach 150 MB. Lookup targets 250 ms and uses only local files; signed USB snapshots are the update channel. The central inventory team owns record corrections.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite index preparation, activation, and lookup belong to the registry. Each kiosk builds its own embedded SQLite database from the signed snapshot. SQLite runs inside the kiosk application and requires no separate service. The registry owns database paths, schema, and queries; callers receive only the fixed lookup result.

### Local Storage and Index

Each prepared snapshot has a separate SQLite database containing:

- Snapshot metadata: schema version and snapshot date.
- Equipment records: original serial number, normalized serial-number key, equipment description, calibration date, and due date.

The normalized key has a unique index with binary comparison. The same normalization routine trims surrounding whitespace and uppercases ASCII letters for both imported serial numbers and lookup input. Punctuation remains significant. Uniqueness validation operates on this key so two source serial numbers cannot map to an ambiguous lookup.

Lookup uses a parameterized equality query on the indexed key. Streaming source records into SQLite keeps import memory independent of the total snapshot size. Lookup does not scan the source JSON. The 250 ms goal needs measurement on representative kiosk hardware with 90,000 records.

### Snapshot Import

Copy the candidate snapshot from approved USB media into a kiosk-local staging area. Validate and build from that local copy so removal or changes to the USB media cannot change bytes between verification and indexing.

The preparation sequence is:

1. Verify the signature manifest using the bundled public key against the local snapshot bytes.
2. Reject an unsupported schema version and validate the snapshot date and records against the supported snapshot schema.
3. Stream the records into a new SQLite database in a transaction. Apply lookup normalization before inserting each unique serial-number key; reject normalization collisions as duplicate serial numbers.
4. Store the snapshot metadata in that database, commit the transaction, and check database integrity and that every validated source record was indexed.
5. Close and durably publish the prepared database, then activate it through the registry’s local active-snapshot reference.

Validation and preparation never mutate the active database. Signature, schema, parsing, duplicate-key, or storage failures discard the candidate and report the failing stage with useful detail. The previous valid snapshot remains active.

### Activation and Lookup Consistency

The active-snapshot reference identifies one complete database. Publish a replacement reference atomically on the same local filesystem only after the prepared database is durable. A lookup pins one database generation for its entire operation, obtaining both the record and snapshot date from that generation. Lookups already in progress may finish against the previous database; subsequent lookups use the newly activated database.

The previous database remains available while readers still hold it. Candidate files left by an interrupted import are never selected as active merely because they exist. On startup, the registry uses the published reference and validates its database before serving lookups.

Durability depends on the kiosk operating system and filesystem supporting the selected atomic-replacement and flush operations. Startup recovery for an unusable published reference needs an explicit policy before implementation.

### Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the pinned database’s unique serial-number index, returning `Found(record, snapshotDate)` for a match or `NotFound(snapshotDate)` for a miss. Both results carry that database’s snapshot date.

`NotFound` describes a successful lookup against a usable snapshot. Initial startup without an imported snapshot, an unreadable active database, and query failures need an availability/error policy; they cannot supply a valid `NotFound(snapshotDate)` result.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index, built on each kiosk | On-site HTTPS directory; managed search service | Offline-only lookup and the absence of a kiosk network route rule out both remote backends. SQLite provides indexed local queries without a service to operate; each kiosk accepts validation, rebuild work, and temporary storage for replacement snapshots. |
| Snapshot replacement | Build a separate database and atomically publish its reference | Rebuild the active database in place | Keeps partially imported records invisible and preserves the last valid snapshot when preparation fails. Readers can finish using a consistent record and snapshot date. |
| Serial-number uniqueness | Unique index over the lookup-normalized key | Uniqueness over original source strings | Aligns import validation with lookup equivalence and prevents two records from matching the same normalized query. |

### Open Questions & Future Decisions

1. What availability/error behavior applies before the first valid snapshot, or when the active database cannot be read? The fixed `Found`/`NotFound` contract has no failure result; a change to that contract requires review with the certificates node.
2. What startup recovery policy applies if the published reference or its database is corrupt? Retaining the previous valid snapshot for recovery also needs a retention and cleanup policy.
3. How are simultaneous import requests handled: reject a second request, queue it, or replace a pending candidate? This determines activation order and temporary storage needs.
4. Which kiosk operating system, filesystem, and SQLite integration supply atomic publication and durable flushes? Measure import disk headroom and lookup latency on that platform.
5. Which concrete snapshot schema versions, signature-manifest format and algorithm, field-validation rules, and whitespace definition are supported? These define validation fixtures and normalization edge cases.
6. What import outcome is reported if activation becomes visible but a later durability operation or acknowledgment fails? The failure boundary determines whether the candidate can safely be discarded.
7. What import API and success/error shape report the failing stage and whether activation occurred?
8. What event defines the lookup’s pinned generation during activation, and how does reader pinning prevent premature database cleanup?
9. Are correctly signed snapshots with older dates, or matching dates and different contents, accepted for activation?
10. Which metadata, schema, and index checks establish that a published database is usable at startup, beyond SQLite integrity checking?

### References

- [GaugeDesk High-Level Design](docs/high-level-design.md)
- [Registry Specifications](docs/intent/registry/registry-specs.md)
- [Certificates Design](docs/intent/certificates/certificates-design.md)

---

**Review findings:** The independent LLD probe identified questions 6–10, particularly the failure boundary after activation becomes visible. I recorded them without choosing policies for you. The current registry specs remain the pre-SQLite baseline pending this design review; the HLD also still describes the backend as open.

**Do you approve this design direction? Please indicate which numbered questions you want resolved in the LLD now and which you want explicitly deferred.**