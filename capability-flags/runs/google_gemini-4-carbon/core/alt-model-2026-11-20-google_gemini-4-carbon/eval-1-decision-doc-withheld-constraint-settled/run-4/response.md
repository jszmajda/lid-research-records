`docs/intent/registry/registry-design.md` is updated with the local embedded SQLite design and its `Decisions & Alternatives` table, and the stale `"Its private lookup backend remains open."` note in `docs/high-level-design.md` is updated to `"its lookup backend is private to the component."` (`certificates` and `registry-specs.md` are untouched pending Phase 2 review).

### Updated `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number at an offline kiosk and need its equipment description, calibration date, and due date. Registry updates arrive on approved USB media as signed snapshots (~90,000 records, up to 150 MB) containing newline-delimited JSON (NDJSON) records, a schema version, a snapshot date, and a signature manifest. Lookups are read-only on the kiosk and complete within 250 ms on 4 GB RAM hardware using local files only.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, where `record` contains the serial number, equipment description, calibration date, and due date. The `certificates` component uses only this interface; storage paths, SQLite schema, and connection handling remain private to `registry`.

`registry` maintains a local embedded SQLite database file in its private data directory alongside an atomic active-snapshot pointer. Each snapshot database contains:

- `snapshot_meta`: single-row table storing `snapshot_date` and `schema_version`.
- `records`: one row per equipment item keyed by `normalized_serial` (`PRIMARY KEY`), storing the display serial number, equipment description, calibration date, and due date.

## Snapshot Import

Snapshot import builds a replacement SQLite database in a local staging path before changing the active snapshot:

1. Verify the signature manifest against the bundled public key over the snapshot metadata and NDJSON payload, and check that `schema_version` is supported.
2. Create a fresh staged SQLite file and stream the NDJSON records line by line inside a single write transaction so memory stays bounded well below the 4 GB kiosk limit on 150 MB snapshots.
3. Validate each record's required fields, compute `normalized_serial` (trimmed surrounding whitespace, ASCII letters uppercased, punctuation preserved), and insert the row into `records`. The `PRIMARY KEY` constraint on `normalized_serial` enforces serial-number uniqueness across normalized forms.
4. Write `snapshot_date` and `schema_version` into `snapshot_meta`, commit and `fsync` the staged SQLite file, atomically repoint the active-snapshot reference to the validated database, switch new lookups to the replacement file, and remove the retired database file once in-flight lookups finish.

If signature verification, schema validation, record parsing, uniqueness checks, or SQLite writes fail, abort and delete the staged file, leave the active snapshot database untouched, and return a descriptive import error.

## Lookup Behavior

`findBySerial(serial)` trims surrounding whitespace and uppercases ASCII letters (`a`–`z` to `A`–`Z`) before querying; internal whitespace and punctuation remain significant. Lookups query the active SQLite database in read-only mode, reading `snapshot_date` from `snapshot_meta` and performing a primary-key lookup on `records.normalized_serial`.

When a matching row exists, return `Found(record, snapshotDate)`; otherwise return `NotFound(snapshotDate)`. Indexed B-tree point lookups over 90,000 local rows keep query latency well within 250 ms without holding the full dataset in memory.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index rebuilt on each kiosk during snapshot import | On-site HTTPS directory; managed search service; direct NDJSON scan or full in-memory map | Kiosks operate without runtime network access, eliminating an on-site HTTPS directory and a managed search service. Among local file options, an indexed SQLite file meets the 250 ms lookup budget across 90,000 records without scanning up to 150 MB of NDJSON per lookup or holding the entire registry in 4 GB of RAM, trading import-time index build work for predictable offline lookups. |
| Snapshot cutover | Build each imported snapshot in a staged SQLite file and swap the active pointer atomically | Replace rows in place inside a single SQLite file | Building a separate staged file avoids write-locking active kiosk lookups during a 90,000-row import and guarantees failed or interrupted imports cannot corrupt or modify the active snapshot. |
```

---

### Phase 2 LLD Edge-Case Probe

A cold read of `registry-design.md` surfaced these internal gaps to resolve in the LLD or defer to `Open Questions & Future Decisions` before moving to Phase 3 (`registry-specs.md`):

1. **Cold kiosk / missing or corrupt database**: What happens when `findBySerial(serial)` is called before any snapshot has ever been imported (no `snapshotDate` exists yet), or if the active SQLite file is unreadable at runtime—does kiosk provisioning require a pre-seeded snapshot, or does `findBySerial` need an `Uninitialized` / error outcome alongside `Found` and `NotFound`?
2. **Snapshot rollback / replay**: What happens when an incoming signed USB snapshot has a `snapshot_date` older than (or identical to) the active snapshot—reject older snapshots unless forced, treat identical `snapshot_date` as a no-op, or accept any validly signed snapshot so inventory can intentionally roll back?
3. **Import entrypoint & concurrent imports**: What function signature and structured error categories should snapshot import expose, and if a second import is triggered while one is already running, should it fail immediately with a busy error or serialize behind a lock?
4. **USB single-pass / TOCTOU & storage bounds**: Should import copy or hash-verify the USB payload in a single pass so USB removal/modification between signature check and NDJSON streaming cannot occur, and should import enforce a max NDJSON line length and free-disk check before staging?
5. **Crash recovery & directory durability**: Should startup sweep orphaned staged/retired SQLite files left behind by a power loss mid-import, and `fsync` the pointer file and parent directory during cutover?
6. **Reader consistency across cutover**: Should each `findBySerial` call run `snapshot_meta` + `records` inside one read transaction against a reference-counted SQLite handle so `snapshotDate` and row lookup always come from the same snapshot and retired files aren't unlinked before open handles drain?
7. **Record & serial boundary inputs**: Should whitespace-only serials (`"   "` → `""`), malformed or inverted dates (`due_date < calibration_date`), zero-record snapshots, or trailing blank NDJSON lines be rejected during import (and whitespace-only lookup queries return `NotFound`)?

How would you like to revise `registry-design.md` or triage items 1–7 (fix now vs. defer) before we advance to Phase 3 (`registry-specs.md`)?