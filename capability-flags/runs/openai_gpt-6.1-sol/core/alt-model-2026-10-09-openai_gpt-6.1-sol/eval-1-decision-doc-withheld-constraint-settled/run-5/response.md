Updated `docs/intent/registry/registry-design.md` with the SQLite design. It fits the HLD’s offline-only architecture and preserves the certificate lookup contract. The backend rationale is recorded in the registry’s Decisions & Alternatives table: the inherited network constraints settle this choice, so a standalone decision document is unnecessary.

## Registry design — for review

**Parent:** `high-level-design`  
**Spec prefix:** `REG`

### Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry owns a local embedded SQLite index built from each accepted snapshot. All validation, index preparation, activation, and lookup use kiosk files. The central inventory team owns record corrections; the kiosk index is read-only after activation.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite storage, and lookup all belong to this node. The SQLite library is embedded in the kiosk application and needs no separately running database service. Database paths, tables, and queries are private registry details.

### SQLite Storage

Each snapshot has a separate database containing equipment records and snapshot metadata. Equipment rows retain the source serial number, equipment description, calibration date, and due date. A normalized serial-number key has a unique index used for exact lookup. Metadata contains the schema version and snapshot date, so records and their date belong to the same database.

The index targets approximately 90,000 records and snapshots up to 150 MB on a kiosk with 4 GB of RAM. Import streams records into the candidate database rather than loading the entire snapshot into memory. Indexed equality queries target the HLD’s 250 ms lookup goal.

### Snapshot Import

Copy the snapshot from approved USB media into a private local staging area. Verify the staged content against the signature manifest using the bundled public key. Reject unsupported schema versions before preparing an index.

Build a candidate SQLite database separately from the active database. Validate and insert records using the same serial normalization as lookup. The unique index detects collisions between normalized serial numbers, including source serials that differ only in surrounding whitespace or ASCII letter case. Finish the database transaction, check database integrity, and close the writer before activation.

The active database continues to serve lookups during candidate preparation. A validation or preparation failure discards the candidate, retains the active database, and reports the failed stage and a useful cause.

### Activation and Lookup Consistency

Store completed databases in distinct local generation paths. An active-generation reference selects the database used for new lookups. Publish a replacement reference atomically only after the candidate database is complete and durable; atomic replacement and durable writes are prerequisites for the kiosk filesystem.

A lookup captures one generation and reads both its equipment data and snapshot metadata from that database. A lookup already using the previous generation can finish after activation; subsequent lookups use the replacement. Retain the previous database until its readers finish. Candidate files are never selected for lookup.

Startup opens the database selected by the active-generation reference rather than treating staging files as active. Crash recovery, generation retention, and startup without a usable active database need the policies listed below.

### Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Use a parameterized equality query against the normalized key; the interface performs exact serial lookup rather than partial or fuzzy search.

Return `Found(record, snapshotDate)` for a match and `NotFound(snapshotDate)` for an absent key. Both results carry the date from the captured database generation. Database failures are not evidence that a serial number is absent; their caller-visible handling remains an open design question.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Local SQLite meets the inherited kiosk-file-only lookup and no-runtime-network constraints. A directory would depend on the lab network and service timeouts; managed search would add external connectivity, credentials, and recurring cost. Each kiosk accepts validation and index rebuilding in exchange for predictable indexed lookups without a service. |
| Replacement preparation | Separate database per snapshot with atomic active-generation publication | Rebuild the active database in place | Keeps the previous snapshot available during preparation and lets each lookup read records and snapshot date from one complete generation. |

### Open Questions & Future Decisions

1. **Unavailable registry:** How should first startup without an accepted snapshot, or failure to open the active database, be reported while preserving the fixed `Found` / `NotFound` result contract?
2. **Recovery and retention:** After interruption during activation, should startup fall back automatically to a retained previous generation or require operator recovery? How many completed generations should be kept?
3. **Snapshot validation details:** Which schema versions, required field formats, signature algorithm, and manifest coverage define an acceptable snapshot? Does an empty snapshot count as valid?
4. **Snapshot ordering:** Should an otherwise valid snapshot with the same or an earlier snapshot date be accepted?
5. **Concurrent imports:** Should a second import be rejected while one is preparing, or queued?
6. **Resource failure:** What local disk-space allowance and operator-facing recovery are needed when staging or rebuilding an index cannot complete?
7. **Activation commit failure:** If atomic reference replacement succeeds but its durability step fails, what import outcome and recovery action should be reported?
8. **Reader lifetime:** How should acquiring a generation protect it against retirement, and how should cancelled or failed lookups release it?
9. **Import error shape:** What structured stage and cause information should imports return, including when candidate cleanup fails?
10. **Lookup input boundaries:** Which whitespace characters are trimmed, and should empty or whitespace-only input return `NotFound` or an input error?

### References

- [GaugeDesk High-Level Design](docs/high-level-design.md)
- [Registry Specifications](docs/intent/registry/registry-specs.md)
- [Certificates Design](docs/intent/certificates/certificates-design.md)

---

The design probe found no concrete internal contradiction. Its highest-priority gaps are **unavailable-registry behavior, activation failure/recovery, and reader lifetime**. Existing registry specs cover the original lookup and replacement behaviors; the SQLite-specific requirements will be drafted after this design review. `git diff --check` passed.

**Do you approve this design direction? Please indicate which numbered questions to resolve now and which to defer, and give any numbered corrections before I move to the EARS specifications.**