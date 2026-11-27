Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (with the backend choice recorded in `Decisions & Alternatives`) and removed the stale "backend remains open" note from `docs/high-level-design.md`.

### Phase 2 Summary — `docs/intent/registry/registry-design.md`

- **Architecture & Storage**: Private read-only SQLite database per active snapshot with `metadata` (`schema_version`, `snapshot_date`) and `equipment` (`serial_normalized TEXT PRIMARY KEY`, `serial_raw`, `description`, `calibration_date`, `due_date`).
- **Snapshot Import**: Verifies signature against bundled public key and checks `schema_version`, streams NDJSON into a separate staging SQLite file in a single transaction (enforcing normalized serial uniqueness via primary key), flushes and runs `PRAGMA quick_check`, atomically swaps the active pointer and reopens the read-only handle, deletes staging on failure while keeping the active DB untouched, and cleans up superseded files once closed.
- **Lookup Behavior**: Normalizes surrounding whitespace and ASCII case (preserving punctuation), queries `equipment` by `serial_normalized`, and returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Records the local embedded SQLite index choice (noting the HLD's offline/no-network constraints eliminate the networked alternatives) and the staging-file atomic swap strategy.

### LLD-Level Edge-Case Probe

Please triage which of these gaps to specify in `registry-design.md` now vs. defer to Open Questions:

1. **Cold-start / no active snapshot**: What happens when `findBySerial(serial)` is called before any snapshot has been imported, or if the active database file is missing/corrupt at startup? (`Found`/`NotFound` both require an active `snapshotDate`.)
2. **Import API & error contract**: What is the import entry point signature, return type, and error taxonomy across failure stages (bad signature, unsupported `schema_version`, malformed record, duplicate serial, disk-full I/O)?
3. **Older or identical `snapshot_date` imports**: Should importing a validly signed snapshot with a `snapshot_date` earlier than or equal to the active snapshot be rejected (enforcing monotonicity) or allowed to replace the active snapshot?
4. **Concurrency during activation and import**: How should in-flight `findBySerial` reads drain during pointer swap, and should concurrent snapshot imports be serialized or rejected?
5. **Crash and power-loss recovery**: How is the active database pointer persisted crash-atomically across power loss, and how are orphaned staging or superseded files cleaned up on startup?
6. **Record-level validation and empty snapshots**: How should malformed NDJSON lines, empty/whitespace-only required fields, malformed or inverted dates (`due_date < calibration_date`), or a zero-record snapshot be handled?
7. **Serial-number normalization edge cases**: How should empty/whitespace-only serials, internal whitespace, or non-ASCII characters be treated on both import and lookup?

Let me know any edits to `registry-design.md` and how you want to triage items 1–7, and confirm when you're ready to proceed to Phase 3 (EARS specs in `docs/intent/registry/registry-specs.md`).