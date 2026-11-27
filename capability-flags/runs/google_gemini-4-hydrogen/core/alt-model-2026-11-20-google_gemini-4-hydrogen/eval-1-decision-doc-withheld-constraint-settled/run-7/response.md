Updated `docs/intent/registry/registry-design.md` (and removed the open-backend note in `docs/high-level-design.md`) to lock in the local embedded SQLite index. Recorded the selection in the LLD's **Decisions & Alternatives** table rather than a standalone decision doc, since the choice is constrained by the HLD's offline tenets and stays private to `registry`.

### Summary of LLD Updates (`docs/intent/registry/registry-design.md`)
- **Architecture**: Specified per-kiosk embedded SQLite storage with no runtime network access.
- **Storage & Schema**: Defined `equipment` (`serial TEXT PRIMARY KEY`, `equipment_description`, `calibration_date`, `due_date`) and `snapshot_meta` (`schema_version`, `snapshot_date`) in the registry's private data directory.
- **Snapshot Import**: Defined streaming NDJSON validation, serial normalization, single-transaction staging DB build, and atomic swap into the active path on success (leaving the prior DB intact on any failure).
- **Lookup Behavior**: Read-only primary-key lookup on normalized `serial` returning `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Captured the lookup backend and staging-swap decisions with alternatives and rationale.

### Phase 2 LLD Edge-Case Probe
Please review the updated `docs/intent/registry/registry-design.md` and triage which of these internal gaps to resolve in the LLD now vs. defer:

1. **Initial / empty states**:
   - What does `findBySerial(serial)` return before any snapshot has ever been imported (no `snapshotDate` exists yet)?
   - Is a valid, signed snapshot with zero equipment records accepted or rejected?
2. **Concurrency, atomic swap, & crash recovery**:
   - How does read-only lookup avoid stale inode reads or locking conflicts during an atomic file swap (and how are SQLite WAL/journal sidecars avoided or finalized before swap)?
   - What happens if two imports run concurrently, or if a prior crashed import left stale staging files behind?
3. **Input, normalization, & record validation**:
   - What happens on empty/whitespace-only `serial` inputs or records, non-ASCII characters, malformed NDJSON lines, missing fields, or invalid/inverted dates?
4. **Snapshot versioning & lookup errors**:
   - Should a valid signed snapshot with an older `snapshot_date` than the active snapshot be allowed or rejected?
   - What error shape does `findBySerial(serial)` return on internal storage/I/O errors (beyond `Found` / `NotFound`)?

Reply with your triage choices and approval of Phase 2 to proceed to Phase 3 (`registry-specs.md`).