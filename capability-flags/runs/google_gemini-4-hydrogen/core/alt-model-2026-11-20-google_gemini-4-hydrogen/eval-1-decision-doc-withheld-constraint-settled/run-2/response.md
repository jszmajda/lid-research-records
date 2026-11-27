Updated `docs/high-level-design.md` and `docs/intent/registry/registry-design.md` to finalize the registry design around the **local embedded SQLite index** (recorded in `Decisions & Alternatives` in `registry-design.md`; no standalone decision doc is needed since the HLD's offline tenets settle the choice and it is internal to `registry`).

### Summary of Registry LLD (`docs/intent/registry/registry-design.md`)
- **Architecture**: `findBySerial(serial)` queries a read-only active SQLite database (`records` table indexed by normalized serial number + snapshot metadata).
- **Snapshot Import**: Verifies signature and schema version, streams NDJSON into a separate staging SQLite database enforcing normalized serial uniqueness, fsyncs and atomically activates the new index, and cleans up the staging file on failure while leaving the previous snapshot active.
- **Lookup Behavior**: Trims surrounding whitespace, uppercases ASCII letters (preserving punctuation), and returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.

### Phase 2 LLD Edge-Case Probe (for triage)
Please review the LLD and let me know which of these internal gaps should be specified in `registry-design.md` vs. deferred to `Open Questions & Future Decisions`:

1. **Uninitialized state**: What happens when `findBySerial(serial)` is called before any snapshot has ever been imported (no `snapshotDate` exists yet)?
2. **Corrupt or missing active index**: What happens if the active SQLite file is missing, unreadable, or corrupted at query time?
3. **Empty / whitespace-only lookup input**: Is `""` or whitespace-only input queried as `NotFound(snapshotDate)` or rejected?
4. **Normalization boundaries**: How are Unicode whitespace, internal whitespace, and non-ASCII characters handled during import and lookup?
5. **Record validation & empty snapshots**: How should zero-record snapshots, blank NDJSON lines, missing required fields, invalid dates, or empty normalized serials be handled?
6. **Import error contract**: What error shape/categories should import failure return (signature failure, unsupported schema, malformed record, duplicate serial, disk/I/O)?
7. **Snapshot date ordering**: Is importing a valid signed snapshot with a `snapshotDate` older than or equal to the active snapshot allowed or rejected?
8. **Signature coverage & payload bounds**: Does the manifest signature cover the full NDJSON payload hash/length (preventing mid-stream truncation), and are size/memory limits enforced?
9. **Concurrent imports**: If a second import starts while one is in progress, is it rejected or serialized, and how are staging paths isolated?
10. **Concurrent reads & atomic swap**: Must the staging database live on the same filesystem/mount as the active database so `rename` is atomic, and how are active readers/SQLite sidecar files handled during replacement?
11. **Crash recovery**: Are orphaned staging files cleaned up on startup/next import, and is the parent directory `fsync`ed after activation?

Reply with your triage decisions and approval of Phase 2 to proceed to Phase 3 (EARS spec updates in `docs/intent/registry/registry-specs.md`).