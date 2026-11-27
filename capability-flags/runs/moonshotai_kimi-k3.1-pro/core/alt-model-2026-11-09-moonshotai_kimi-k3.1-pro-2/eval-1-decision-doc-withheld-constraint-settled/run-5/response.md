## Phase 2 stop — registry design review

Updated `docs/high-level-design.md` to identify the local embedded SQLite backend and drafted `docs/intent/registry/registry-design.md`:

### Public Interface and Ownership

`findBySerial(serial)` returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Certificates cannot see database paths, connections, SQL, or import state. The registry owns validation, index construction, activation, connections, and lookup.

### SQLite Representation

Each snapshot gets a complete SQLite database containing:

- Metadata: schema version and snapshot date.
- Records: normalized serial number as primary key, original serial number, equipment description, calibration date, and due date.

Lookups use an exact primary-key query through a read-only connection. Record and snapshot date are read from the same connection, preventing mixed-snapshot results during activation.

### Snapshot Import and Activation

- Verify the signature and schema version before indexing.
- Stream records into a separate staging database.
- Enforce serial uniqueness through the primary key.
- Atomically replace an active-snapshot pointer only after database finalization succeeds.
- Never write imports into the active database.
- Keep existing readers on their selected version; activation affects subsequent lookups.
- Discard failed staging databases and retain the active snapshot.

### Decisions Recorded

| Decision | Chosen | Alternatives | Rationale |
|---|---|---|---|
| Backend | Embedded SQLite | HTTPS directory; managed search | Predictable local indexed lookups without network, credentials, service cost, or another process. |
| Import isolation | Versioned database plus atomic pointer | Update active DB; overwrite active file | Protects the active snapshot and in-flight readers. |
| Lookup | Read-only exact primary-key query | Table scan; shared writable connection | Indexed access without a separate search structure or mutation risk. |
| Result consistency | Read record and date from one connection | Separate global metadata read | Prevents mixed-snapshot results. |

## Edge-case probe

These questions need resolution or an explicit decision to defer before I update EARS:

1. **No available snapshot:** How should lookup behave before the first successful import or when no active pointer exists? The current result types cannot represent the absence of a snapshot date.
2. **Active database failure:** If the selected database is missing, unreadable, corrupt, or incompatible, should lookup fail explicitly or fall back to an older valid snapshot?
3. **Record validation:** Should malformed NDJSON, missing fields, invalid dates/text, empty snapshots, or truncated input reject the entire import?
4. **Normalization and uniqueness:** Should uniqueness be checked after the same normalization used for lookup? What whitespace counts as surrounding whitespace, and are empty-after-normalization serials rejected?
5. **Concurrent imports:** Should imports be serialized so an earlier request cannot activate after a later one?
6. **Activation interruption:** After pointer-replacement failure or power loss, must the previous snapshot remain active, or is either complete snapshot acceptable after restart?
7. **Operational errors:** What import and lookup error variants should callers receive for storage exhaustion, permissions, and SQLite failures?
8. **Record contract:** What exact field types and date representation should the fixed registry result expose?

Connection pooling, concrete SQLite pragmas, file naming, and obsolete-file cleanup can remain implementation details unless you want them constrained now.

Please approve the design and resolve or defer the eight questions above. I’ll then update the registry EARS specifications and present their consistency report for review.