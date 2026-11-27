**Phase 2: Registry LLD Draft**

Updated `docs/intent/registry/registry-design.md` to select and define the embedded SQLite approach.

```markdown
# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. The registry turns each accepted snapshot into a kiosk-local SQLite database so lookup remains available without a network dependency.

## Public Interface

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are independent of SQLite. The certificates node uses only this interface and cannot read the index or its files.

## SQLite Index

Each active snapshot has one SQLite database containing its snapshot date and its equipment records. The records table stores the serial number used for lookup, equipment description, calibration date, and due date. The lookup serial is the record serial with surrounding whitespace removed and ASCII letters converted to uppercase; punctuation is retained. It is the table's unique key and lookup index.

The registry opens the active database read-only for lookups. A successful query returns the matching record and the database's snapshot date. A miss returns `NotFound` with that same date. SQLite configuration, file locations, and connection lifetime remain private to this node.

## Snapshot Import and Activation

Import creates a new SQLite database in a staging location on the kiosk's registry storage volume. The registry verifies the snapshot signature with the bundled public key, rejects unsupported schema versions, and streams the records into the staged database. Inserting records under the normalized lookup serial detects duplicate lookup identities before activation.

The staged database becomes eligible for activation only after signature verification, schema validation, record loading, uniqueness validation, and database finalization all succeed. Activation replaces the active database as one publish operation; lookups use either the complete previous database or the complete replacement, never a staged or partially loaded database. A rejected or failed import discards its staging database, retains the previous active database, and reports the failure category to the technician.

## Resource Boundaries

Import work is bounded to the received snapshot and its staged database. The active index remains readable while a replacement is prepared. The registry needs storage for the active database and one staged replacement; it does not retain a search service, network client, or independently maintained secondary index.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Embedded SQLite index on each kiosk | On-site HTTPS directory; managed search service | SQLite keeps serial-number lookup available on isolated kiosks, gives predictable indexed reads for the 90,000-record registry, and confines snapshot validation, index construction, and query behavior to the registry component. |
| Snapshot publication | Build and validate a staged database before one activation publish | In-place database update; expose JSON directly | A separate staged database prevents malformed or incomplete imports from changing the index serving technicians. |
| Lookup identity | Trim outer whitespace and uppercase ASCII letters before enforcing uniqueness and querying | Exact serial matching; punctuation-insensitive matching | It matches technician input normalization while preserving punctuation that may distinguish equipment serial numbers. |

## Open Questions & Future Decisions

### Deferred

1. Define the platform-specific durable activation mechanism and recovery behavior if kiosk power fails during publication.
2. Define the retention policy for a previously active database after a successful replacement.
```

The HLD remains coherent: local files, no runtime network access, and an internal registry backend are preserved.

**LLD Gap Probe**

Please resolve or defer these decisions before the EARS specs are revised:

1. What should `findBySerial` do before the first successful import, or if the active database is unreadable or corrupt? Its current two-result interface has no error state.
2. What durable activation and startup-recovery rule should protect the active index if power fails during publication?
3. Should imports be serialized? In particular, what happens if a second import starts while another import or activation is in progress?
4. May lookups that began before activation complete against the prior snapshot while later lookups use the new one?
5. Is “surrounding whitespace” ASCII-only or Unicode-aware? This affects lookup equivalence and duplicate detection.
6. Which record fields are mandatory and validated during import, including serial number, description, calibration date, due date, and snapshot date?
7. Must the signature cover the schema version and snapshot date as well as the record payload?
8. Should a failed staged-database cleanup be retained for recovery/diagnostics or removed on the next startup?
9. After successful activation, should the prior database be deleted immediately, retained temporarily for rollback, or retained until storage pressure requires removal?

Please approve the draft and answer the applicable questions, or explicitly defer them, to proceed to Phase 3.