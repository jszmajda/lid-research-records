Updated `docs/intent/registry/registry-design.md` with the SQLite design. The backend choice is recorded in its **Decisions & Alternatives** table: the HLD’s offline-only constraint rules out both service options, so a table row captures the rationale adequately.

## Registry design — Phase 2 review

### Context and architecture

The registry provides kiosk-local lookup over approximately 90,000 equipment records. Signed USB snapshots supply updates; index construction happens during import.

SQLite runs embedded in the kiosk application. Snapshot validation, index construction, activation, and lookup belong to the registry. Database paths, connections, schemas, and query details remain private.

The public interface remains:

```text
findBySerial(serial)
  → Found(record, snapshotDate)
  | NotFound(snapshotDate)
```

Each prepared snapshot has its own SQLite database containing equipment records, snapshot date, and schema version. A unique index covers the normalized serial-number key. Certificates continue using only the public lookup interface.

### Snapshot import

1. Stage the snapshot in kiosk-local storage and verify its signature using the bundled public key.
2. Check the schema version and validate records. Normalize serial numbers using the lookup rule and check normalized-key uniqueness.
3. Stream records into a separate candidate SQLite database in a transaction. Store metadata and construct the unique index without loading the entire snapshot into memory.
4. Complete the candidate database and verify that it can be opened and queried.
5. Publish the completed database through an atomic active-snapshot reference change.

Validation and construction never modify the active database. Failed imports preserve the previous snapshot and report the failed stage with a useful error.

Snapshots may reach 150 MB. Import needs storage for the candidate alongside the active database. Activation durability and interrupted-import recovery remain review questions.

### Lookup and consistency

Lookup trims surrounding whitespace, uppercases ASCII letters, and preserves punctuation. Import applies the same normalization; serial numbers that normalize to the same key count as duplicates.

A parameterized equality query uses the unique index. Records and snapshot dates come from the same database, including the date returned with `NotFound`.

Active databases are read-only. Each lookup holds one database for its duration. New lookups use the newly activated database; existing readers finish against their original database before it can be reclaimed.

### Capacity and performance

Indexed lookup targets the HLD’s **250 ms** goal on a kiosk with **4 GB RAM** and approximately **90,000 records**. Import uses streaming input and bounded batches. Representative kiosk measurements must establish whether the latency goal is met.

### Decisions and alternatives

| Decision | Selected approach | Alternatives and rationale |
|---|---|---|
| Lookup backend | Local embedded SQLite | HTTPS and managed search require connectivity, conflicting with the HLD. SQLite provides indexed lookup without an operated service; each kiosk bears validation, storage, and index-building work. |
| Snapshot preparation | Separate database, activated as a unit | Updating the active database during import complicates preservation of the last valid snapshot and reader consistency. |

### Open questions recorded in the design

1. **Unavailable registry:** What should lookup do before the first import or when the active database is unreadable? Neither existing result type represents unavailability.
2. **Activation and recovery:** What durability is required after power loss, how should startup recover, and how long should previous databases remain?
3. **Record validation:** Which fields and date formats are mandatory, and should malformed records reject the whole snapshot?
4. **Import ordering:** May older signed snapshots be accepted, and how should simultaneous imports behave?

## Edge-case probe

The independent LLD probe confirmed those gaps and identified additional details for your triage:

5. **Activation commit point:** If publication succeeds but cleanup or reporting fails, is the import successful? The failure guarantee needs an explicit boundary.
6. **Signed-content binding:** Precisely which records and metadata does the signature cover, and how is verified staged content kept unchanged during construction?
7. **Input and error contracts:** What happens with empty or invalid lookup input? What error information should failed imports return?
8. **Snapshot identity:** How should two snapshots with the same date be distinguished or ordered?

The HLD still describes the backend as open. Updating that summary would cross into the parent design, so it needs your approval. `git diff --check` passed.

**Do you approve this LLD, including normalized-key duplicate rejection and the HLD summary update? Please identify which numbered gaps to resolve now versus defer, and give your preferred behavior for those to resolve.**