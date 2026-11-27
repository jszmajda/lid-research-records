Updated `docs/intent/registry/registry-design.md` with the SQLite design. I also corrected the HLD’s stale “backend remains open” wording.

The choice is recorded in the registry’s **Decisions & Alternatives** table. A standalone decision doc isn’t needed: the inherited offline constraint rules out the network-backed alternatives, and the choice stays inside the registry.

## Registry design — for review

### Context and design philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The kiosk operates without a network route. The registry uses an embedded SQLite index built locally from each accepted USB snapshot. Each kiosk owns the validation and rebuild cost; the central inventory team owns record corrections and snapshot production.

### Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, SQLite database preparation, activation, and lookup all belong to this node. The registry owns database paths, connections, and query details. Certificates consume only the lookup result.

### SQLite storage

Each prepared snapshot has a separate SQLite database containing:

- An equipment table with a unique indexed normalized serial key, the source serial number, equipment description, calibration date, and due date.
- Snapshot metadata containing the snapshot date and source schema version.

Normalize serial keys by trimming surrounding whitespace and converting ASCII letters to uppercase. Preserve punctuation. Apply the same normalization during import and lookup so that the index represents the lookup identity. Uniqueness is checked on normalized keys, including collisions between differently written source serial numbers.

The database is a derived lookup artifact, built from the signed snapshot rather than accepted as a supplied database. Once prepared, it is immutable and opened read-only for lookups. Records and their snapshot date reside in the same database.

### Snapshot import

1. Verify the snapshot signature using a bundled public key and reject unsupported schema versions before accepting records into the registry.
2. Stream the newline-delimited JSON into a staging SQLite database separate from the active database. Validate records against the supported schema and derive their normalized serial keys. Reject duplicate keys.
3. Complete and commit the equipment index and snapshot metadata, then verify that the prepared database can be opened for lookup.
4. Publish the completed database as the active snapshot in one activation step. Partially prepared databases are never eligible for lookup.

A validation, database-build, or activation failure leaves the previous valid database selected and reports the failing stage and a useful cause. Staging work does not modify active records. Each kiosk builds its own replacement index when a snapshot arrives.

### Activation and lookup consistency

A lookup uses one selected database for both the equipment query and snapshot date. Activation changes the database selected for new lookups; a lookup already using the previous database finishes against that database. Keep a previous database available until its readers finish. This prevents a record from one snapshot being paired with the date of another.

The durable activation mechanism, restart recovery rules, and handling of overlapping imports need review before implementation.

### Lookup behavior

Normalize the requested serial number and issue a parameterized equality query against the unique serial index. Return `Found(record, snapshotDate)` for a match and `NotFound(snapshotDate)` for a successful query with no match. Both results use metadata from the database queried.

The lookup path uses only kiosk-local files. The design targets the HLD’s 250 ms lookup goal on a 4 GB kiosk with approximately 90,000 records. Streaming import avoids holding a snapshot of up to 150 MB in memory; indexed equality lookup avoids scanning the full registry. Measurement on representative kiosk hardware is needed to verify the latency goal.

### Decisions & Alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD requires kiosk-local lookup without runtime network access. SQLite provides indexed lookup without a service, accepting validation and rebuild work on every kiosk. Remote alternatives centralize maintenance but require prohibited connectivity. |
| Replacement preparation | Separate immutable database per snapshot | Rebuild the active database in place | Separate preparation keeps the last valid snapshot readable after validation or construction failure and gives activation a completed unit to publish. |
| Serial index identity | Unique normalized serial key | Unique source serial text | Matching import and lookup identity rules prevents multiple source records from matching one lookup key. |

### Open questions and edge-case probe

1. **Unavailable registry:** What does lookup return before the first valid snapshot is installed, or if the active database cannot be read? The existing contract describes only successful queries.
2. **Power loss:** What durable activation and restart-recovery behavior is required if power fails during publication? The mechanism also depends on filesystem and operating-system constraints.
3. **Import ordering:** Should overlapping imports be rejected, queued, or allowed to supersede one another? What policy applies to older or repeated signed snapshots?
4. **Snapshot acceptance:** Which record values are invalid beyond serial-key duplication, and what exact manifest and schema rules define acceptance? How are imported bytes bound to verified bytes if the USB source changes during import?
5. **Storage and readers:** What reserve and cleanup policy covers active, staging, and previous databases? How is database selection coordinated with reader registration so cleanup cannot race that handoff?
6. **Import errors:** What concrete error shape identifies the failing stage and cause, and distinguishes import failure from lookup unavailability?

### References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
- `docs/intent/certificates/certificates-design.md`

---

The edge-case probe found no conflict between SQLite and the HLD’s offline constraints. It highlighted source-file mutation, reader/cleanup races, and import-error shape as gaps needing explicit treatment. `git diff --check` passed.

**Do you approve this LLD direction? Please identify which numbered gaps you want resolved in the design now and which you want deferred.** After that review, the next phase is the corresponding EARS update.