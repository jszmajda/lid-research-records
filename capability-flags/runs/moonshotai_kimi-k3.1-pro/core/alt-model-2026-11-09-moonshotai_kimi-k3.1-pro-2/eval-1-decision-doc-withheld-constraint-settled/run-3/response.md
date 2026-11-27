## Phase 2 — Registry LLD draft

Updated:

- `docs/high-level-design.md` to identify SQLite as the registry’s private backend.
- `docs/intent/registry/registry-design.md` with the completed draft below.
- The certificate interface remains unchanged.

### Registry Design

#### Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry owns all snapshot and storage details. Its implementation must keep lookups available with no network route and must never expose a partial or invalid replacement snapshot.

#### Public Interface

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are independent of SQLite. The certificates node uses only this interface and cannot access registry files, connections, SQL, or backend configuration.

#### SQLite Storage

Store the active registry in one application-owned SQLite database on the kiosk. The database contains:

- `records`, with one row per equipment record and columns for normalized serial number, original serial number, description, calibration date, and due date;
- a unique index on normalized serial number, implemented as the table's primary key; and
- `metadata`, holding the active snapshot date and schema version.

The registry opens SQLite in WAL mode so readers can continue using the committed snapshot while an import is prepared. SQLite remains an implementation detail: no SQL or database handle crosses the registry boundary. The 90,000-record target needs no server process or external credentials, and primary-key lookup avoids scanning or loading the snapshot into memory.

#### Snapshot Import

Verify the signature with the bundled public key and reject unsupported schema versions before changing registry data. Stream the newline-delimited records into a staging table rather than accumulating the snapshot in memory. Validate serial-number uniqueness through constraints on both the original and normalized values; surrounding-whitespace and ASCII-case variants therefore cannot create two indistinguishable lookup keys.

Build and validate the staging table inside one SQLite transaction. Only after every record and the metadata are valid, replace the live records with the staged records within that same transaction and commit. Readers see either the previously committed generation or the complete replacement, never staging rows or a mixture of generations. On any validation, write, or commit failure, roll back the transaction, discard staging data, report a useful import error, and keep the previous snapshot active.

WAL recovery restores the last committed state after an interrupted import. Imports require temporary disk space for the incoming records and SQLite transaction data; they do not require a second registry service.

#### Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters in application code before lookup. Serial-number punctuation remains significant; SQLite collation does not perform serial normalization. Query `records` by the normalized primary key and join the result with the active snapshot metadata. Return the snapshot date for both Found and NotFound results.

A lookup uses the committed database state and does not contact an external service. SQLite availability and query failures are registry errors rather than alternative NotFound results.

#### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Private embedded SQLite index | On-site HTTPS directory; managed search service | Meets offline operation with predictable primary-key lookup and no running service; keeps snapshot validation and index maintenance inside the registry. |
| Snapshot activation | Stage and replace within one SQLite transaction | Replace the active database file after import | SQLite transaction isolation gives existing readers a complete old or new generation and rolls back failed imports without exposing staging data. |
| Serial matching | Application normalization plus a unique normalized key | SQLite `NOCASE`; raw-text matching | Makes supported ASCII normalization explicit while preserving punctuation and preventing ambiguous normalized keys. |

Deferred questions currently recorded in the LLD:

1. Behavior when no valid snapshot has ever been installed.
2. Handling of an existing database that fails SQLite integrity checks.

### LLD edge-case probe

The independent probe identified these decisions needing your judgment:

1. **Unavailable results:** Before the first valid import, there is no snapshot date for either existing result variant. During WAL recovery or database corruption, lookup availability is also unclear. Should these states raise an error, add another result variant, or block lookup?
2. **Error contract:** The interface currently has no representation for SQLite failures. Should lookup/import errors be exceptions, typed result variants, or another error channel?
3. **Commit failures:** SQLite cannot always prove that a reported commit failure left no committed transaction. Should the old-snapshot guarantee apply only to failures known to occur before a successful commit, with uncertain outcomes reconciled during recovery?
4. **Record validity:** The design does not define rejection rules for malformed JSON, missing fields, empty serials, invalid dates, invalid metadata, or an empty snapshot.
5. **Replacement ordering:** Should older or same-date snapshots be accepted, and should concurrent imports be serialized or rejected?
6. **Original-serial uniqueness:** Staging enforces both original and normalized uniqueness, but live storage specifies only the normalized key. Should both remain enforced after activation?

Which of these would you like resolved in the LLD, and which should remain deferred? Once those decisions and the draft are approved, I’ll proceed to the registry EARS updates.