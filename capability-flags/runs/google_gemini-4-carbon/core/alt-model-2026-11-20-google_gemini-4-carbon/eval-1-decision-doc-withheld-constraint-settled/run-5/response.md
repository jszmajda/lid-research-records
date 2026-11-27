`docs/intent/registry/registry-design.md` is updated with the local embedded SQLite design and its `Decisions & Alternatives` entries, and `docs/high-level-design.md` has a one-line coherence update removing `"Its private lookup backend remains open."` (`Owns snapshot validation and lookup; keeps its lookup index private.`). `certificates` is untouched since `findBySerial(serial)` and its result types are unchanged.

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, where `record` carries the equipment description, calibration date, and due date. The certificates node uses only this interface; SQLite files, schema, and storage paths stay private to this node.

Snapshot validation, SQLite index construction, active-snapshot switching, and lookup all run in-process inside this node using an embedded SQLite library with no separate service or runtime network access.

## Index Storage and Schema

Each imported snapshot builds a self-contained, immutable SQLite database file in the kiosk's local registry directory:

- `metadata`: single row storing `snapshot_date` and `schema_version`.
- `records`: keyed by `normalized_serial TEXT PRIMARY KEY`, with `description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, and `due_date TEXT NOT NULL`.

An active-snapshot pointer file in the same local directory names the currently active SQLite database file. Updating that pointer via write-to-temp and atomic rename switches snapshots without mutating an active database in place.

## Snapshot Import

Import processes a signed snapshot package from approved USB media in four stages:

1. **Envelope validation**: Verify the signature manifest against the snapshot payload using the bundled public key and check that `schema_version` is supported before allocating or populating an index.
2. **Streamed staging build**: Stream the newline-delimited JSON records into a staging SQLite file inside a single write transaction, keeping memory usage bounded on a 4 GB kiosk for snapshots up to 150 MB and 90,000 records.
3. **Record normalization and uniqueness**: Normalize each record's serial number (trim surrounding whitespace, uppercase ASCII letters `a`–`z`, preserve punctuation) and insert into `records`. Reject the import if any record is malformed or collides on `normalized_serial`.
4. **Atomic activation**: Write `snapshot_date` and `schema_version` to `metadata`, commit and sync the staging SQLite file, open the new read-only snapshot handle against it, atomically replace the active-snapshot pointer file (syncing pointer file and directory), and swap the in-process active handle reference.

If any step before pointer replacement fails, close any staging handles, delete the staging SQLite file, keep the previously active snapshot serving lookups unchanged, and return a descriptive import error.

## Lookup Behavior

Open the active snapshot SQLite file in read-only mode and cache `snapshot_date` alongside the snapshot handle from `metadata`.

On `findBySerial(serial)`, trim surrounding whitespace and uppercase ASCII letters (`a`–`z` to `A`–`Z`) while leaving punctuation unchanged. Execute a parameterized primary-key lookup against `records.normalized_serial`:

- Match found: return `Found(record, snapshotDate)`.
- No match: return `NotFound(snapshotDate)`.

In-flight lookups retain a reference to the read-only snapshot handle they started with so concurrent snapshot activation never interrupts an active query or mixes `record` and `snapshotDate` across snapshots.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on each snapshot import | On-site HTTPS directory; managed search service; scanning raw NDJSON or holding a full in-memory map | Satisfies the HLD offline/no-runtime-network tenet without external services, credentials, or network timeouts; bounds RAM on 4 GB kiosks for 150 MB snapshots while keeping 90,000-record point lookups well under 250 ms; keeps index lifecycle private to Registry. |
| Snapshot activation | Build a fresh immutable SQLite file in staging and atomically swap the active pointer | Mutate a single SQLite database in place within a write transaction | Avoids write-lock contention with concurrent kiosk lookups during 90,000-row imports and guarantees a failed or interrupted import leaves the active database file untouched. |
| Serial-number key | Normalize serial numbers on import and store `normalized_serial` as `PRIMARY KEY` | Query-time `UPPER(TRIM(...))` scan or custom SQLite collation on raw serials | Applies whitespace and ASCII-case normalization identically at import and lookup, enforces uniqueness under lookup equivalence, and uses a standard B-tree primary-key lookup. |
```

---

### Phase 2 LLD Edge-Case Probe

Please let me know which of these internal gaps to resolve in `registry-design.md` now versus record under `Open Questions & Future Decisions` as deferred:

1. **Pre-snapshot / corrupt startup state**: What happens when `findBySerial(serial)` is called on a newly provisioned kiosk before any snapshot has been imported (since both `Found` and `NotFound` require `snapshotDate`), or when the active-snapshot pointer/SQLite file is missing or corrupt on startup?
2. **Import interface and error taxonomy**: What callable signature and input shape should snapshot import expose (e.g., `importSnapshot(packagePath)`), and should callers receive typed failure categories (invalid signature, unsupported schema version, malformed/duplicate record, storage I/O) or a descriptive message? Also, how should `findBySerial` surface unexpected local SQLite read errors?
3. **Older / duplicate / empty snapshots**: What happens when a validly signed snapshot has a `snapshot_date` older than (or equal to) the active snapshot, or contains zero records — are rollbacks and empty snapshots permitted or rejected?
4. **USB staging vs. two-pass read & size bounds**: Should snapshot verification and indexing copy/verify the USB package in a single pass (or stage locally first) so USB removal/modification mid-import cannot cause a TOCTOU mismatch between Stage 1 and Stage 2, and should imports enforce hard caps above 150 MB / 90,000 records?
5. **Disk cleanup and concurrent imports**: When are superseded SQLite files and leftover crash-interrupted staging files deleted once in-flight lookups drain, and should concurrent import calls serialize on a lock or reject immediately while an import is already running?
6. **Record validation & returned `serial` field**: Should blank/whitespace-only serial numbers, missing/invalid calendar dates (`calibration_date`, `due_date`, `snapshot_date`), or blank descriptions reject the import, and should `Found(record, snapshotDate)` also include the canonical or original serial string on `record`?

Once you triage these items and approve the Phase 2 LLD, we will move to Phase 3 (`docs/intent/registry/registry-specs.md`).