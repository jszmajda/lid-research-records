Updated `docs/intent/registry/registry-design.md` for the local embedded SQLite index (and updated `docs/high-level-design.md` to reflect that the registry lookup backend is now selected).

Here is the updated `docs/intent/registry/registry-design.md` for Phase 2 review:

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed; the certificates node uses only this interface.

Snapshot validation, local SQLite index management, and lookup all belong to this node. The index is stored as a local embedded SQLite database file on the kiosk's filesystem and opened read-only during lookups. Storage paths, schema details, and query mechanics are private to this node.

## SQLite Index Schema & Storage

The active SQLite database holds two tables:

- `metadata`: stores `snapshot_date` and `schema_version` for the active snapshot.
- `equipment`: stores `normalized_serial` (TEXT PRIMARY KEY), `serial` (TEXT NOT NULL), `description` (TEXT NOT NULL), `calibration_date` (TEXT NOT NULL), and `due_date` (TEXT NOT NULL).

Indexing on `normalized_serial` as the primary key provides predictable O(log N) lookups for ~90,000 records well within the 250 ms latency target and 4 GB RAM budget, with no external service or runtime network access. Lookup connections open the active database in read-only mode.

## Snapshot Import

1. Verify the snapshot signature using a bundled public key and reject unsupported schema versions.
2. Parse the newline-delimited JSON records, normalize serial numbers, and validate that all serial numbers are unique.
3. Build a fresh SQLite database in a staging file on the same filesystem, populating `equipment` and `metadata` within a single transaction and closing it cleanly so no stray journal or WAL files remain.
4. Atomically replace the active database path with the staged file only after all validation and build steps succeed.

An import failure at any step discards the staging file, leaves the previous active SQLite database untouched, and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters on the input serial number before querying `equipment` by `normalized_serial`. Serial-number punctuation remains significant. Read `snapshot_date` from `metadata` and return it in both `Found(record, snapshotDate)` and `NotFound(snapshotDate)`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; Managed search service | Keeps lookups completely offline on the kiosk with no runtime network route or external service credentials, satisfies <250 ms lookups for 90,000 records within 4 GB RAM, and contains snapshot validation and index lifecycle inside the registry node. |
| Snapshot activation | Stage new SQLite file and atomically swap | In-place table rebuild in active database | Ensures a failed or interrupted import never corrupts or partially exposes the active index, and avoids write-lock contention with read-only lookups. |

## References

- `docs/high-level-design.md`
- `docs/intent/registry/registry-specs.md`
```

### LLD Edge-Case Probe

Please triage which of these gaps to resolve in the LLD now vs. defer to `## Open Questions & Future Decisions`:

1. **Cold start with no active snapshot:** What happens when `findBySerial(serial)` is called before any snapshot has ever been imported (no active SQLite file exists), given that both `Found(record, snapshotDate)` and `NotFound(snapshotDate)` require a `snapshotDate`?
2. **Unreadable or corrupt active database:** What does `findBySerial(serial)` return or raise if the active SQLite file is unreadable, corrupt, or missing its `metadata` row?
3. **Import API and failure shape:** What is the import entry point's signature and return/error contract, and how are distinct failure causes (invalid signature, unsupported schema version, malformed JSON, duplicate normalized serial, I/O error) represented?
4. **Empty or malformed record fields:** What happens when `findBySerial(serial)` receives an empty or whitespace-only string, and what happens during import if a record has an empty/whitespace-only `serial` or missing/null `description`, `calibration_date`, or `due_date`?
5. **Non-ASCII and internal whitespace in serials:** Since normalization trims surrounding whitespace and uppercases ASCII letters while preserving punctuation, what happens when a serial in a snapshot or lookup contains non-ASCII characters, internal whitespace, or control characters?
6. **Older or equal `snapshot_date` import:** What happens when a valid, signed snapshot is imported whose `snapshot_date` is older than or equal to the currently active snapshot—is it accepted or rejected?
7. **Zero-record snapshots:** What happens when a valid, signed snapshot contains zero equipment records—is it accepted as an empty registry or rejected?
8. **Concurrent imports:** What happens if a snapshot import is triggered while another import is already in progress (e.g., serialized, rejected, or risking staging-path collision)?
9. **Read-only connection lifecycle across atomic swap:** Does `findBySerial(serial)` open and close a fresh read-only SQLite connection per call, or if connections are reused/pooled, what happens to an open handle to the unlinked previous file after an atomic swap?
10. **Crash cleanup of staging files:** What happens to orphaned staging or journal files left behind if the process crashes or loses power mid-import—when and how are they cleaned up?

Let me know your feedback on the LLD, how you'd like to triage these edge cases, and whether we're approved to proceed to Phase 3 (EARS spec review/update).