Updated `docs/intent/registry/registry-design.md` to finalize the local embedded SQLite index design (and removed the stale "Its private lookup backend remains open." line from `docs/high-level-design.md`).

### Updated `docs/intent/registry/registry-design.md`

- **Architecture**: `findBySerial(serial)` is backed by a local embedded SQLite database on the kiosk; validation, index preparation, atomic activation, and read-only lookup stay inside the `registry` node.
- **Snapshot Import**: Verifies signature and schema version, streams NDJSON records into a single-transaction staging SQLite file (`records` table keyed by normalized `serial` `PRIMARY KEY`, plus `metadata` for `snapshot_date` and `schema_version`), fsyncs, and atomically replaces the active database path only after all validation succeeds. Failures discard the staging file and keep the active database untouched.
- **Lookup Behavior**: Normalizes surrounding whitespace and uppercase ASCII letters while preserving punctuation; queries the active SQLite database in read-only mode (`WHERE serial = ?`) and returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- **Decisions & Alternatives**: Recorded the `Lookup backend` row selecting the local embedded SQLite index over the on-site HTTPS directory and managed search service. (No separate decision doc was created or offered, since the HLD's offline/no-network-route tenets settle the choice and it affects only this node.)

---

### Phase 2 LLD Edge-Case Probe (for triage)

Please triage which of these internal `registry` gaps should be specified in `registry-design.md` now vs. deferred:

1. **Missing or uninitialized active database**: What happens when `findBySerial(serial)` is called before any snapshot has been imported, or if the active SQLite file is missing/unreadable? (`Found`/`NotFound` both require `snapshotDate`.)
2. **Concurrent lookups, SQLite handles, and concurrent imports**: How are cached read-only connections and journal/WAL sidecars handled during atomic path replacement, and what prevents two concurrent imports from racing on staging or activation?
3. **Crash recovery and staging placement**: What happens to orphaned staging files after a power loss/crash mid-import, and is staging guaranteed to live on the same filesystem/mount as the active database so rename is atomic?
4. **Snapshot date ordering (rollback / replay)**: Should import reject or allow a valid, signed snapshot whose `snapshot_date` is older than (or identical to) the currently active snapshot?
5. **Import entry point, error shapes, and manifest scope**: What is the import function signature/input shape and structured error type ("report a useful error"), and does the signature manifest cover `schema_version` and `snapshot_date` in addition to the NDJSON records?
6. **Normalization and record validation edge cases**: How are empty/whitespace-only serials, internal whitespace, non-ASCII characters, zero-record snapshots, or invalid/inverted dates (`due_date < calibration_date`) handled?
7. **Size and memory bounds during streaming import**: Is uniqueness enforced solely via the SQLite `PRIMARY KEY` on disk (avoiding an in-memory set on 4 GB RAM kiosks), and are snapshot/line size limits enforced?

---

**Phase 2 Review**: Please confirm which gaps above you want addressed in `registry-design.md` (or deferred), and whether I have your approval to proceed to **Phase 3** (updating `docs/intent/registry/registry-specs.md`).