Updated `docs/intent/registry/registry-design.md` with the SQLite design below.

The backend choice needs a decision-table row rather than a standalone decision document: the HLD’s offline-only constraint rules out both service options, so a future reader can reconstruct the choice from a short rationale.

## Registry design — for review

**Parent:** `high-level-design` · **Spec prefix:** `REG`

### Context and design philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

All lookup data resides on the kiosk. The central inventory team owns record corrections; each kiosk validates and indexes replacement snapshots from approved USB media. The registry targets 90,000 records, snapshots up to 150 MB, and serial-number lookups within 250 ms on a kiosk with 4 GB of RAM.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite index preparation, activation, and lookup all belong to the registry. SQLite is embedded in the kiosk application and requires no database service. The registry keeps its database schema, connections, and storage paths private.

### SQLite storage

Each accepted snapshot has its own SQLite database containing the snapshot date and schema version alongside the equipment records. Records retain the serial number, equipment description, calibration date, and due date supplied by the snapshot. A separate normalized serial key supports exact indexed lookup; serial-number punctuation remains significant.

The active database is opened for read-only lookup. Replacement databases are built in a separate staging location on the kiosk so import work cannot mutate the active records. Snapshot metadata and records belong to the same database, allowing a lookup to return a record and date from one snapshot.

### Snapshot import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Stream the newline-delimited records into the staged SQLite database rather than retaining the entire snapshot in memory. Build the serial-key index before making the database available for lookup.

Activate the staged database only after signature, schema, record, and index preparation checks succeed. Publish the completed database as one snapshot; partially imported records are never visible to lookup. A failed validation or database build leaves the previous snapshot active and reports a useful error. Staged data is disposable and is never selected as the active snapshot merely because it exists on disk.

### Lookup behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Apply the same normalization when constructing index keys. Serial-number punctuation remains significant. Use a parameterized exact-key query through the SQLite index rather than scanning records or invoking a network service.

Each lookup holds a reference to one active database for its full duration. Return the snapshot date from that database even when no matching record exists. During replacement, an in-flight lookup can finish against the previous database; subsequent lookups use the newly activated database. Retain the previous database while readers still reference it.

### Decisions & alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Both service options violate the inherited local-files-only constraint. SQLite provides indexed exact lookups without a service to operate; each kiosk accepts snapshot validation and index rebuilding. |
| Replacement preparation | Build a separate database, then activate the complete snapshot | Rebuild the active database in place | Isolates import failures from the last valid snapshot and lets existing readers finish with matching records and snapshot metadata. |

### Open questions from the edge-case probe

1. **Unavailable registry:** How should lookup report that no valid snapshot exists or the active database cannot be read? `NotFound(snapshotDate)` cannot describe those cases.
2. **Duplicate keys:** Should serial numbers that collide after whitespace and ASCII-case normalization cause rejection?
3. **Interrupted activation:** What durable activation and restart-recovery mechanism should select between the previous database and the completed replacement?
4. **Older or repeated snapshots:** Are older snapshots accepted, and what identifies a repeated import?
5. **Record validation:** What rules apply to missing fields, malformed dates, empty serial numbers, and an empty snapshot?
6. **Overlapping imports:** How are concurrent imports ordered, and exactly when does a lookup acquire the replacement database?
7. **Authenticated content:** Which bytes and metadata are signed, and how should import handle source files changing between verification and indexing?
8. **Input normalization:** Which whitespace characters are trimmed, and how are empty or invalid lookup inputs handled?
9. **Failures and resource bounds:** What error categories and limits apply to disk exhaustion, oversized records, publication failures, and database cleanup? How is lookup latency protected during index construction?

### References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`

---

**Review findings:** The SQLite design fits the HLD’s offline architecture. The probe highlighted the open questions above, especially activation recovery and unavailable-registry behavior. `git diff --check` passed.

One upstream wording issue also needs your approval: the HLD still says the backend “remains open.” May I change that to “uses a private local SQLite index”?

**Please approve or revise the design, and indicate which numbered gaps to resolve now versus defer.** This is the LLD review stop before updating the EARS specifications.