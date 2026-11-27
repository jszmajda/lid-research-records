Updated `docs/high-level-design.md` (Phase 1 coherence: recorded the local SQLite index in the Registry architecture summary) and finished `docs/intent/registry/registry-design.md` (Phase 2 LLD).

### Summary of Registry LLD Changes (`docs/intent/registry/registry-design.md`)
- **Storage & Index Schema**: Single self-contained, read-only SQLite database per active snapshot with `records` (`serial TEXT PRIMARY KEY`, `description`, `calibration_date`, `due_date`) and `snapshot_meta` (`schema_version`, `snapshot_date`).
- **Snapshot Import & Atomic Activation**: Verify signature and `schema_version`, stream-parse NDJSON into a staging SQLite DB (normalizing serials and enforcing uniqueness via `PRIMARY KEY`), finalize as a single file, and atomically swap into the active path; delete staging on any failure.
- **Lookup Behavior**: Normalize input `serial` (trim whitespace, ASCII uppercase, preserve punctuation), query by primary key on the active read-only DB, and return `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Recorded the SQLite choice (with the networked alternatives eliminated by the HLD's offline tenets, and in-memory NDJSON rejected for 4 GB RAM kiosks), staging-and-swap activation, and ingest+query normalization. *(No standalone decision doc offered, as the HLD's offline constraints settle the networked options and the choice is local to `registry`.)*

### Phase 2 LLD Edge-Case Probe (Gaps to Triage)
Please indicate which of these to resolve in `registry-design.md` now vs. defer under Open Questions:
1. **Initial / missing active snapshot**: What happens when `findBySerial(serial)` is called before any snapshot has been imported (or if the active DB file is missing), given the return type only models `Found(record, snapshotDate)` and `NotFound(snapshotDate)`?
2. **Corrupt or inconsistent active DB**: What happens when `findBySerial(serial)` encounters a corrupted/unreadable SQLite file or a `snapshot_meta` table with zero or multiple rows?
3. **Empty or non-ASCII serials**: What happens when `findBySerial(serial)` is called with an empty/whitespace-only string (or non-ASCII characters), or when an imported record's `serial` normalizes to empty?
4. **Concurrent lookup during swap / concurrent imports**: What happens if a `findBySerial` query (or persistent read-only connection) is active when the DB file/pointer is swapped, or if two snapshot imports run concurrently?
5. **Crash recovery & orphaned staging files**: What happens on startup/next import if power loss or a crash interrupts staging or atomic activation, leaving orphaned temp files or journal sidecars?
6. **Malformed NDJSON & empty snapshots**: What happens when a snapshot has zero records, blank lines, invalid JSON, `null`/empty required fields, invalid date formats, or extra fields?
7. **Import API contract & snapshot ordering**: What happens if an operator imports a valid signed snapshot whose `snapshot_date` is older than or equal to the active snapshot, and what import entry-point signature / error shape is expected?

Review `docs/high-level-design.md` and `docs/intent/registry/registry-design.md`, let me know how you'd like to triage items 1–7, and confirm when you're ready to proceed to Phase 3 (updating `docs/intent/registry/registry-specs.md`).