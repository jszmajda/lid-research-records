I have updated the design for the local embedded SQLite index and paused at the **Phase 2 (LLD) stop** for your review.

### Changes Made
1. **`docs/high-level-design.md`**: Updated the `Registry` line under `## Architecture` to reflect that it owns snapshot validation, local index preparation, and lookup (removing *"Its private lookup backend remains open."*).
2. **`docs/intent/registry/registry-design.md`**:
   - **Architecture**: Specified the local embedded SQLite database as the private lookup backend, keeping the `findBySerial(serial)` interface (`Found(record, snapshotDate)` / `NotFound(snapshotDate)`) unchanged.
   - **Snapshot Import**: Added staged SQLite build (signature verification, schema check, normalized serial uniqueness check, staging DB indexing + `snapshotDate` metadata, atomic activation on success, and staging cleanup on failure).
   - **Lookup Behavior**: Specified normalized serial-number point queries against the active read-only SQLite database.
   - **Decisions & Alternatives**: Recorded the `Lookup backend` choice (`Local embedded SQLite index` over `On-site HTTPS directory` and `Managed search service`) with rationale. *(No standalone decision doc was created or offered, since the choice is settled by the HLD's offline/no-network tenets and remains private to `registry`.)*

### Phase 2 LLD Edge-Case Probe
Please triage which of these internal gaps should be resolved in `registry-design.md` now versus deferred as open questions:

1. **Initial / uninitialized state**: What does `findBySerial(serial)` return or raise on first boot before any snapshot is imported (when no `snapshotDate` exists yet)?
2. **Lookup error & failure states**: What happens if the active SQLite database is missing, unreadable, or corrupted (`SQLITE_CORRUPT`)?
3. **Concurrent lookup during swap**: How are in-progress `findBySerial(serial)` reads (or open read-only handles) handled when a newly staged SQLite database is atomically activated?
4. **Crash recovery & stale artifacts**: When and how are leftover staging files or superseded database files cleaned up after a mid-import crash?
5. **Invalid or edge-case serial inputs**: How should `findBySerial(serial)` handle empty/whitespace-only strings, control characters, non-ASCII characters, or internal whitespace?
6. **Record-level validation during import**: If a snapshot contains malformed JSON lines, missing/empty fields, or invalid date formats, is the entire import rejected?
7. **Snapshot-level edge cases**: What happens for an empty (zero-record) snapshot, a `snapshotDate` older than or equal to the active snapshot, or a payload exceeding the 150 MB / 4 GB RAM budget?
8. **Signature vs. payload mismatch**: What happens if the signature manifest verifies, but the NDJSON payload, schema version, or `snapshotDate` metadata is missing or truncated?
9. **Storage & resource failures during staging**: How are disk-full or I/O errors handled while building or finalizing the staged SQLite database (including journal/WAL files)?
10. **API & error shapes**: What are the exact field types for `record` and `snapshotDate`, and the import interface/error shape for distinct failure modes?

**Next step:** Once you confirm the LLD updates and let me know how to triage the probe items above, I will update `registry-design.md` accordingly and proceed to **Phase 3 (EARS spec review/update)**.