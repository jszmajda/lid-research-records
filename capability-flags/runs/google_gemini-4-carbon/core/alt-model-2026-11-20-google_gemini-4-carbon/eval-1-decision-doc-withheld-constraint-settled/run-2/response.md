`docs/intent/registry/registry-design.md` is updated with the local embedded SQLite design and a `Decisions & Alternatives` entry (and `docs/high-level-design.md` has the stale *"Its private lookup backend remains open"* clause updated to *"its lookup backend stays private to this component"* so the HLD and LLD stay coherent).

### Phase 2 Output — `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number on an offline metrology kiosk and need its equipment description, calibration date, and due date alongside the date of the registry snapshot in use. Central inventory distributes signed snapshots on approved USB media; each snapshot bundles newline-delimited JSON (NDJSON) equipment records, a schema version, a snapshot date, and a signature manifest.

The registry component owns snapshot verification, local index construction, atomic activation, and read-only serial-number lookup within the kiosk's 4 GB RAM and 250 ms lookup budgets across roughly 90,000 records (snapshots up to 150 MB).

## Architecture

The registry exposes two operations on local kiosk storage:

- `findBySerial(serial)` -> `Found(record, snapshotDate)` | `NotFound(snapshotDate)`
- `importSnapshot(snapshotBundlePath)` -> `ImportSuccess(snapshotDate, recordCount)` | `ImportError(reason)`

`record` contains the canonical serial number, equipment description, calibration date, and due date. The certificates component depends only on `findBySerial(serial)` and its fixed result types; SQLite database paths, schema, and query mechanics remain private to the registry component.

Each valid snapshot is materialized on local disk as a self-contained, read-only SQLite database file. An active-snapshot pointer identifies the SQLite file currently serving lookups.

## SQLite Storage and Schema

Each snapshot database contains two tables:

| Table | Columns | Purpose |
|---|---|---|
| `snapshot_meta` | `id INTEGER PRIMARY KEY CHECK (id = 1)`, `schema_version INTEGER NOT NULL`, `snapshot_date TEXT NOT NULL` | Single-row metadata bound to the same file as the records it describes. |
| `equipment_records` | `normalized_serial TEXT PRIMARY KEY`, `serial TEXT NOT NULL`, `description TEXT NOT NULL`, `calibration_date TEXT NOT NULL`, `due_date TEXT NOT NULL` | Point-lookup table indexed by normalized serial number (`WITHOUT ROWID`). |

Keying `equipment_records` on `normalized_serial` as a `WITHOUT ROWID` B-tree primary key gives single-index point lookups without an extra table heap probe and enforces post-normalization serial uniqueness at the storage layer. Storing `snapshot_meta` inside the same SQLite file guarantees that `record` and `snapshotDate` come from one coherent snapshot.

## Snapshot Import

Snapshot import runs against a staging directory on the same local filesystem as the active registry store:

1. **Signature verification**: Verify the snapshot's signature manifest against the public key bundled with the kiosk software before parsing snapshot metadata or records.
2. **Header validation**: Confirm `schema_version` is supported and `snapshot_date` is well-formed.
3. **Staged index build**: Create a new staging SQLite file and stream the NDJSON records inside a single write transaction so the full 150 MB payload does not reside in memory at once. Normalize each record's serial number before insert; any duplicate `normalized_serial`, malformed JSON line, or missing required field aborts the transaction.
4. **Durability and activation**: Commit and `fsync` the staging SQLite file, open and verify a read-only handle, and atomically update the active-snapshot pointer on the local filesystem so subsequent lookups use the new database. Remove the superseded SQLite file once in-flight lookups against it finish.

If any step fails, the import deletes any staging artifacts, leaves the previously active SQLite database untouched, and returns an `ImportError` describing the validation or I/O failure.

## Lookup Behavior

`findBySerial(serial)` normalizes the input by trimming leading and trailing whitespace and converting ASCII lowercase letters (`a`–`z`) to uppercase (`A`–`Z`). Internal whitespace and punctuation (such as hyphens, slashes, and periods) remain significant, and the same normalization function runs during both snapshot import and lookup.

Each lookup acquires a reference to the current read-only SQLite handle, queries `equipment_records` by `normalized_serial` together with `snapshot_date` from `snapshot_meta`, and returns `Found(record, snapshotDate)` on a match or `NotFound(snapshotDate)` when no row matches. Using a single database handle per call ensures an activation mid-lookup never mixes a record from one snapshot with the date of another.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service; linear NDJSON scan or full in-memory map | HLD constraints prohibit runtime network access and external services on isolated kiosks, ruling out an on-site HTTPS directory and a managed search service. Among local file designs, an embedded SQLite B-tree index meets the 250 ms lookup budget across 90,000 records without holding a 150 MB snapshot in RAM on a 4 GB kiosk, while keeping all storage mechanics private to the registry component. |
| Index update strategy | Build a new immutable SQLite file in staging per snapshot and swap on completion | Mutate a single persistent SQLite database in place within a transaction | Writing a fresh staged file isolates media errors, validation failures, and interrupted imports from the active database and avoids blocking read-only lookups while a 90,000-row snapshot is indexed. |
```

---

### Phase 2 LLD Edge-Case Probe

Please let me know which of these gaps to resolve directly in the LLD now versus defer under `Open Questions & Future Decisions`:

1. **Cold kiosk before first snapshot import**: What happens when `findBySerial` is called on a newly provisioned kiosk before any snapshot has been imported (since both `Found` and `NotFound` require a `snapshotDate`)—does kiosk startup require a pre-seeded snapshot, or should `findBySerial` return an explicit `NoActiveSnapshot` / error state?
2. **Missing or corrupted active SQLite file**: What happens if the active-snapshot pointer is dangling on startup or SQLite reports corruption / local disk I/O failure during a lookup—fail closed at startup/lookup with an explicit storage error, or another behavior?
3. **Empty or whitespace-only serial numbers & whitespace scope**: What happens when a record's `serial` in NDJSON normalizes to `""` (reject the snapshot as invalid?), and when `findBySerial("")` or whitespace-only input is called (`NotFound(snapshotDate)` vs. invalid-input error)? Also, should trimming strip ASCII whitespace only or all Unicode whitespace?
4. **Canonical `record.serial` value returned in `Found`**: When an imported record has `" ab-12 "`, should `record.serial` return the normalized form (`"AB-12"`, making a separate `serial` column unnecessary) or preserve original casing from the snapshot?
5. **Older, same-date, or empty snapshots**: What happens when a validly signed snapshot has a `snapshot_date` older than or equal to the active snapshot, or contains zero records—reject older/empty snapshots as `ImportError`, or allow signed rollbacks?
6. **Date and field validation rules on import**: Should `snapshot_date`, `calibration_date`, and `due_date` enforce strict ISO-8601 calendar dates (`YYYY-MM-DD`), and should empty-string `description` or `due_date < calibration_date` reject the snapshot?
7. **`ImportError(reason)` shape and concurrent imports**: Should `reason` be a typed error code enum (e.g., `InvalidSignature`, `UnsupportedSchema`, `DuplicateSerial`, `MalformedRecord`, `IoError`) plus detail message, and if `importSnapshot` is called while another import is running, should it serialize or reject immediately?
8. **Crash cleanup of staged/superseded files and key rotation**: Should registry startup purge leftover staging files and unreferenced SQLite files after an interrupted import/swap, and does signature verification use a single pinned public key or a small bundled keyring to allow key rotation?

Let me know your feedback on the LLD and how you'd like to triage items 1–8 before we move to Phase 3 (`registry-specs.md`).