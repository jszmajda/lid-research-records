Updated `docs/intent/registry/registry-design.md` with the SQLite design draft. **The design is ready for your Phase 2 review**, with unresolved policies called out below.

The backend choice needs a Decisions & Alternatives row rather than a separate decision document: the HLD already requires kiosk-local lookup with no runtime network access, which rules out both service options under the current architecture.

## Registry design draft

### Context and design philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

Registry data comes from signed USB snapshots and remains read-only during kiosk operation. The registry owns the local index and its lifecycle. The design targets approximately 90,000 records, snapshots up to 150 MB, and serial-number lookups within 250 ms on a kiosk with 4 GB of RAM.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite index preparation, activation, and lookup all belong to this node. Each kiosk builds its own embedded SQLite database from the signed snapshot. The certificate component sees only the lookup result; database files, connection management, and import details remain private to the registry.

### Local SQLite index

Each prepared snapshot has its own database file containing:

- Snapshot metadata: schema version and snapshot date.
- Equipment records: normalized serial-number key, source serial number, equipment description, calibration date, and due date.

The normalized serial-number key is unique and indexed for exact lookup. Import and lookup use the same normalization: trim surrounding whitespace and uppercase ASCII letters, preserving punctuation. SQLite compares the resulting keys exactly rather than applying a separate case-insensitive collation.

Build the database by streaming the snapshot records into a transaction, keeping memory use independent of the full snapshot size. After preparation, the database is opened read-only for lookups. A parameterized equality query on the indexed key returns the equipment record, and the snapshot date comes from that same database generation.

### Snapshot import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness after normalization. Prepare the new snapshot without exposing partially imported records. Activate it only after all validation succeeds. An import failure leaves the previous snapshot active and reports a useful error.

The import path is:

1. Copy the snapshot into private local staging so signature verification and index construction use the same captured bytes.
2. Verify the signature and schema version, then stream records into a new SQLite database with the normalized key’s uniqueness constraint enforced.
3. Commit the prepared database, check its integrity, and verify that its metadata can be read through the lookup path.
4. Publish the prepared database as the active generation using a durable, atomic replacement of a small local descriptor identifying its database file.

The prepared database and descriptor live on the kiosk’s local filesystem. Publication uses a same-filesystem atomic rename after the new database and descriptor are durably written. The active database is never rebuilt in place. Only one import prepares or publishes a replacement at a time.

Signature, schema, record parsing, uniqueness, SQLite preparation, and storage failures are reported with the failed stage and useful diagnostic detail. A failure before publication discards staging without changing the active descriptor. The durable descriptor is the authority for which generation is active after restart.

### Activation and lookup consistency

Each lookup pins one active database generation for both the record query and snapshot date. Publication changes the generation used by new lookups; lookups already using the previous generation finish against it. An in-process activation lock coordinates descriptor publication and generation selection.

Release the previous database’s lookup connections only after its in-flight lookups finish. Cleanup removes unreferenced staging files and retired generations without deleting the active database or a database still in use. Recovery policy for an unreadable active database and retention of an additional fallback generation remain open design questions.

### Lookup behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Return the snapshot date even when no matching record exists.

A missing indexed key produces `NotFound(snapshotDate)`; a storage failure is not evidence that the serial number is absent.

### Decisions & Alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on each kiosk | On-site HTTPS directory; managed search service | The HLD requires lookups from kiosk files with no runtime network access. SQLite provides indexed exact lookup without a service, credentials, or connectivity dependency; each kiosk accepts validation, rebuild time, and temporary storage for replacement snapshots. The service alternatives would require an HLD change. |
| Replacement preparation | Separate database generation with atomic descriptor publication | Rebuild the active database in place | Failed preparation leaves the last valid snapshot usable. A pinned generation keeps each record and its snapshot date consistent during activation. |
| Serial-number index key | Normalize at import and lookup, then compare exactly | Store raw serial numbers and normalize during queries | A shared normalized key makes indexed lookup predictable and catches source records that would otherwise resolve to the same lookup key. |

### Open questions and edge-case probe

The probe identified these questions for your triage:

1. **Unavailable registry:** What should lookup do before the first snapshot is installed, or when the active database cannot be read? `Found`/`NotFound` has no unavailable outcome. Adding one would require a certificate-segment review.
2. **Normalized duplicates:** Should serials differing only in surrounding whitespace or ASCII case reject the entire snapshot? The draft treats these as duplicates.
3. **Corruption recovery:** Should startup automatically use a retained previous generation, or report unavailability until a valid import? This determines fallback retention and disk-space needs.
4. **Snapshot freshness:** Are older or same-date signed snapshots accepted? Authenticity alone does not settle rollback policy.
5. **Concurrent import requests:** Should a second request queue or report that an import is already running?
6. **Publication failure boundary:** What result and recovery behavior apply if descriptor replacement succeeds but durability confirmation or the in-process generation switch fails?
7. **Signature coverage:** Which exact bytes does the manifest authenticate, including schema version and snapshot date?
8. **Record validity:** Which conditions reject a snapshot: blank normalized serials, missing fields, invalid dates, inconsistent calibration and due dates, or an empty record set?
9. **Cleanup ownership:** How does cleanup distinguish an in-progress prepared generation from abandoned staging, including after restart?
10. **Import error contract:** What structured result exposes failure stage and category separately from diagnostic detail?

### References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`

---

The pre-flight found the existing registry specifications consistent with the baseline design and the certificate lookup contract. There are no tests or implementation files yet. `git diff --check` passes.

**Do you approve this design direction? Please reply with numbered feedback and identify which open questions we should resolve now versus defer.** The next phase is the corresponding EARS update after this review.