Updated the design for the local embedded SQLite index (Phase 2):

- **`docs/high-level-design.md`**: Updated the Registry architecture line to state that it owns snapshot validation, local index preparation, and lookup.
- **`docs/intent/registry/registry-design.md`**: Completed the registry design with local staging SQLite database creation, metadata binding (`snapshotDate`, `schemaVersion`), indexed normalized-serial storage, atomic database replacement, read-only point lookup, and a `Decisions & Alternatives` row recording `Local embedded SQLite index` (settled by the HLD's offline/no-network tenets and contained within the registry node, so no separate decision doc is needed).

### Phase 2 Edge-Case Probe (`registry-design.md`)

A blind LLD-level edge-case probe surfaced these internal gaps to triage (fix in `registry-design.md` vs. defer):

1. **Cold start (no snapshot yet)**: What happens when `findBySerial(serial)` is called before any snapshot has been imported and no active SQLite database exists?
2. **Empty / whitespace / non-ASCII input**: What happens when `findBySerial(serial)` receives `""`, whitespace-only input, or non-ASCII characters—normalize and return `NotFound(snapshotDate)`, or reject?
3. **Normalized serial collisions**: What happens when two records have distinct raw serials (e.g., `"ab-12"` and `" AB-12 "`) that collide after whitespace trimming and ASCII uppercasing—reject the entire import?
4. **Concurrent lookup during atomic swap**: What happens if `findBySerial(serial)` holds an open SQLite connection (or WAL/journal sidecars) when an import atomically replaces the active database file?
5. **Concurrent imports**: What happens if a second snapshot import starts while another import is already validating or building the staging SQLite database?
6. **Crash recovery**: What happens on startup after a crash or power loss leaves an orphaned staging database or leftover journal/WAL files on disk?
7. **Stale / older snapshot**: What happens when a valid, signed snapshot has a `snapshotDate` older than (or equal to) the currently active snapshot—allow downgrade or reject?
8. **Corrupted active database**: What happens if the active SQLite file is corrupted, unreadable, or missing its metadata row during `findBySerial(serial)`, given the fixed `Found` / `NotFound` return types?
9. **Input boundaries & parse order**: What happens when a snapshot exceeds 150 MB, or contains malformed JSON lines / trailing blank lines—is signature verification guaranteed before parsing?
10. **Import error contract**: What is the snapshot import's return type and structured error shape (e.g., distinguishing signature failure, schema mismatch, duplicate/invalid record, and disk/SQLite I/O failure)?

Which of these should be resolved in `docs/intent/registry/registry-design.md` now vs. deferred under `Open Questions & Future Decisions`, and may I proceed to Phase 3 (`docs/intent/registry/registry-specs.md`) once those are settled?