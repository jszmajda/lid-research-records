Saved the SQLite registry draft in `docs/intent/registry/registry-design.md`. I also removed the stale “backend remains open” wording from the HLD.

The offline constraints settle the backend choice, so its rationale belongs in the registry’s decision table rather than a separate decision document.

## Registry design — for review

**Parent:** high-level-design  
**Spec prefix:** REG

### Context and design philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

Registry lookup runs entirely on the kiosk. Signed USB snapshots are the source of inventory data; the local index is a derived, read-only lookup representation. Each kiosk validates and builds its own index. The design targets approximately 90,000 records, snapshots up to 150 MB, and lookup within 250 ms on a kiosk with 4 GB of RAM.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite database construction, activation, and lookup all belong to the registry. SQLite is embedded in the kiosk application and requires no service process. Database paths, connections, and query details are private to the registry.

Each prepared snapshot has its own database file. The active database is opened read-only for lookups; an import builds a separate candidate database. A lookup uses one database generation for both the record and snapshot date so activation cannot combine data from different snapshots.

### SQLite storage

The candidate database contains:

- A metadata table holding the snapshot date and source schema version.
- A records table holding the fixed registry record fields and a normalized serial-number key.
- A unique index on the normalized serial-number key, using exact binary comparison.

The same normalization function generates import keys and lookup keys: trim surrounding whitespace and uppercase ASCII letters, preserving punctuation and non-ASCII letter case. Uniqueness is checked after normalization; two source serials that produce the same lookup key cannot identify separate records.

Records are streamed into the candidate database within a transaction rather than loading the full snapshot into memory. The database contains the fields needed to construct the existing lookup result without consulting USB media. Snapshot metadata is stored with the records so results remain associated with their source snapshot.

### Snapshot import

1. Copy the candidate snapshot from USB into private local staging storage. Signature verification and database construction use those same staged bytes.
2. Verify the signature using a bundled public key and reject unsupported schema versions.
3. Stream the records into a separate SQLite database, validating records against the supported source schema and enforcing normalized serial-number uniqueness.
4. Commit the completed candidate database and verify that it can be opened for read-only lookup with its snapshot metadata.
5. Publish the completed database by atomically replacing the local active-database reference. Only a fully validated and prepared candidate is eligible for publication.

The active-database reference names one complete database generation. The reference and database files live on local storage supporting atomic reference replacement. Database preparation never modifies the active generation. Lookups already using the previous generation finish against it; new lookups use the published generation. Retired database files are removed only after their readers have finished.

An invalid signature, unsupported schema version, invalid record, duplicate normalized serial, or preparation failure rejects the candidate and reports the failed import stage and cause. A failed import leaves the previous snapshot available. Staging storage and the candidate database can be discarded without altering the active generation.

The persistent active-database reference selects the generation on application startup. Recovery from interrupted publication and the durability guarantee for abrupt power loss remain design questions below.

### Lookup behavior

Acquire the active database generation, normalize the input, and execute a parameterized equality query against the unique serial-number index. Construct `Found(record, snapshotDate)` for a match or `NotFound(snapshotDate)` for an absent key, obtaining the date from that same generation. Serial-number punctuation remains significant.

Lookup requires only local files and the embedded SQLite library. Keeping the query on a unique index avoids scanning the full registry for each request. The 250 ms goal needs verification on kiosk-class hardware with a representative 90,000-record snapshot; the index alone is not evidence that the target is met.

### Decisions & alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Both service options require connectivity forbidden by the HLD. SQLite supports indexed lookup without running a service; each kiosk validates snapshots and rebuilds its own index. |
| Snapshot preparation and activation | Separate immutable database generations with atomic publication | Rebuild the active database in place | Preserves the last valid snapshot on import failure, keeps partial records out of lookups, and lets existing readers finish consistently. |
| Serial-number comparison | Shared normalization with a unique binary-comparison key | Raw-serial uniqueness; database collation-based matching | Import uniqueness agrees with lookup normalization, preserves punctuation, and avoids broader locale-dependent case folding. |

### Open questions from the edge-case probe

Please triage these as **resolve now** or **defer**, adding your preferred behavior where you have one:

1. **Unavailable registry:** What happens before the first valid snapshot, or when the active database cannot be opened? The current result type does not define an unavailable state.
2. **Power-loss recovery:** What recovery and durability guarantee applies if power is lost during activation?
3. **Snapshot ordering:** Can an older signed snapshot replace a newer one, and how are repeated imports identified?
4. **Concurrent imports and disk space:** Are simultaneous imports rejected or queued? How much space is reserved for staging, candidate databases, and retained generations?
5. **Validation details:** Which whitespace characters are trimmed? How are empty input and non-ASCII serials validated? What are the exact source-schema fields, date formats, and signature coverage?
6. **Error contract:** How are runtime lookup failures represented? How do callers distinguish import rejection, operational failure, and cancellation?
7. **Publication lifecycle:** How is reader acquisition synchronized with retirement? If publication succeeds but cleanup or completion reporting fails, what import outcome is reported?
8. **Verified-byte protection:** What protects staged bytes from modification between signature verification and database construction?
9. **Snapshot completeness and limits:** Are empty snapshots valid, how is completeness established, and are the stated size and record-count goals also import limits?

### References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`

---

The draft fits the HLD’s offline architecture. Existing registry specs cover normalization, snapshot dates, rejection, and atomic visibility; the SQLite-specific obligations will need corresponding EARS updates after this design review. `git diff --check` passed.

**Do you approve this design direction, and which numbered gaps should we resolve before moving to the EARS phase?**