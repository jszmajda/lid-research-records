Updated `docs/intent/registry/registry-design.md` with the SQLite design below. The backend decision belongs in the registry’s decision table: the HLD already requires local-only lookup, which rules out both service options.

This is the **LLD review stop**. The existing EARS cover the baseline lookup and import behavior; SQLite-specific requirements follow after this design is approved.

## Registry Design

```yaml
parent: high-level-design
prefix: REG
```

### Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry serves approximately 90,000 records on kiosks with 4 GB of RAM. Snapshots arrive on approved USB media and can be up to 150 MB. Lookup uses kiosk-local files, with a target completion time of 250 ms. The central inventory team owns record corrections; kiosk registry data is read-only between imports.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite preparation, activation, and lookup belong to the registry. Each kiosk builds a private embedded SQLite database from the signed snapshot. The database is a derived lookup index, not an independently editable inventory. Registry storage paths, SQL, and connection management remain private to this node.

The certificate component receives the same record fields and result types through `findBySerial(serial)`. Backend selection imposes no change on that interface.

### SQLite Storage

Each snapshot generation has its own SQLite database. A metadata table holds the schema version and snapshot date. An equipment table holds the normalized serial key and the equipment description, calibration date, and due date. The normalized serial key is the primary key, providing an indexed exact-match query and enforcing uniqueness under lookup normalization.

Use parameterized queries. Lookup connections open the activated database read-only. Store the full record data needed for lookup in the database so a query does not scan the source JSON or depend on the USB device remaining attached.

### Snapshot Import

Copy the snapshot into a private local staging area so signature verification and indexing use the same bytes. Verify the signature using a bundled public key and reject unsupported schema versions before activation. Stream the newline-delimited records into a new SQLite database, rather than retaining the entire snapshot in memory.

Normalize each serial using the lookup normalization before insertion. A duplicate normalized key rejects the snapshot. Build the equipment and metadata tables in a transaction. Commit, check database integrity, and close the build connection before making the generation eligible for activation. Validation or preparation failure discards the candidate and reports a useful import error while preserving the active generation.

### Activation and Lookup Consistency

Keep the candidate database separate from the active database throughout preparation. Publish a completed generation by atomically replacing a small local active-generation reference. The database and reference are stored on the same local filesystem; publication occurs only after the candidate is complete and durable.

A lookup pins one generation for the entire operation. Both the equipment query and snapshot date come from that generation. A lookup already in progress can finish against the previous generation; a lookup starting after publication uses the replacement. Old generation files are retained while readers still use them.

After a restart, resolve the published active-generation reference and open that completed database. Unpublished staging files cannot become active merely because they exist. Cleanup of staging or retired files is separate from publication and cannot remove a generation still needed by readers.

### Lookup Behavior

Trim surrounding whitespace and convert ASCII lowercase letters to uppercase before lookup. Serial-number punctuation remains significant. Apply exactly the same normalization during import and lookup.

Query the equipment primary key for an exact match. Return `Found(record, snapshotDate)` for a matching key and `NotFound(snapshotDate)` otherwise. The date comes from the pinned database metadata, including for a missing record. Database access failures are not evidence that a serial is absent; their outward error contract remains an open question.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Kiosk-local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD requires every lookup to use kiosk-local files and forbids runtime network access. Both service options require connectivity; SQLite provides indexed exact lookup without a service, at the cost of validation and index rebuilding on each kiosk. |
| Snapshot publication | Immutable database generations with an atomic active-generation reference | Rebuild the active database in place | Separating preparation from publication preserves the last valid snapshot after a failed import and lets each reader observe a complete record set with its matching snapshot date. |
| Import memory use | Stream records into the candidate database | Load all JSON records into memory before indexing | Bounds import memory use for snapshots up to 150 MB on 4 GB kiosks while SQLite enforces normalized-key uniqueness. |

### Open Questions & Future Decisions

- Define startup and lookup behavior before the first valid snapshot is installed; the current result type assumes a snapshot date exists.
- Define the outward error contract for unreadable or corrupt active storage, including whether recovery selects a retained generation or requires an explicit re-import.
- Define import result and error shapes, including publication failure and failures after the active-generation reference becomes visible.
- Define the exact publication ordering point and reader-pinning protocol so retirement cannot race with a reader acquiring a generation.
- Set policy for snapshots whose date is older than, or equal to, the active snapshot date.
- Define record-field validation, date formats, empty serial handling, and the precise surrounding-whitespace character set.
- Specify the returned record shape, including whether it retains the original serial spelling, and the accepted lookup input domain.
- Define concurrent import handling, retained-generation cleanup, and behavior when disk space is insufficient for staging plus both database generations.
- Specify signature-manifest coverage and supported schema versions, and confirm atomic publication and crash durability on the kiosk filesystem.

### References

- [GaugeDesk high-level design](docs/high-level-design.md)
- [Registry specifications](docs/intent/registry/registry-specs.md)
- [Certificates design](docs/intent/certificates/certificates-design.md)

---

## Review questions

The independent registry-local probe found the gaps recorded above. Its strongest finding is that the declared `Found`/`NotFound` interface cannot yet express **no installed snapshot** or **storage failure**.

Please give numbered feedback:

1. **Design approval:** Does the SQLite storage, staged import, and generation-publication design match your intent?
2. **Gap triage:** Which open questions should we resolve in this LLD, and which should remain deferred? In particular, should we settle missing-snapshot and storage-error behavior now?
3. **HLD consistency:** May I update the HLD’s “private lookup backend remains open” sentence to reflect the SQLite selection?

`git diff --check` passed.