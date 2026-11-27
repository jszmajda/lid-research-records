Now I'll run an LLD-level edge-case probe to identify gaps in this design.

## LLD-Level Edge-Case Probe

The following "what happens when..." questions target gaps in the registry LLD:

1. **What happens when the active `registry.db` file is corrupted?** — Does the component detect corruption on startup, and what action does it take? Does it fall back to a previous snapshot, or does lookup fail until a new valid snapshot is imported?

2. **What happens when disk space runs out during staging index build?** — Is there a size pre-check before starting the build? How is the partial staging file cleaned up? Does the error message distinguish disk-full from other import failures?

3. **What happens when a lookup is in progress while the atomic file rename occurs?** — Does the active SQLite connection detect the swap? Does the lookup see the old index or the new one, or does it error? What does WAL mode guarantee here?

4. **What happens if the bundled signature verification key is missing or corrupted?** — Does the component fail fast on startup or only when an import is attempted? Is there a key integrity check at initialization?

5. **What happens when `registry-staging.db` already exists from a previous failed import?** — Is it silently overwritten, or does the import check and clean up stale staging files first?

6. **What happens when normalization produces an empty string or a serial consisting only of whitespace?** — Is this accepted as a valid serial, rejected during import, or handled as a special case during lookup?

7. **What happens when the snapshot contains duplicate serials that normalize to the same value** (e.g., "ABC-123" and "abc-123")? — The spec says reject duplicates, but does "duplicate" mean pre-normalized or post-normalized comparison?

8. **What happens if the `metadata` table is missing or corrupted in the active index?** — Does lookup fail entirely, return a sentinel snapshot date, or attempt to reconstruct the metadata from somewhere?

9. **What happens when the first lookup occurs before any snapshot has ever been imported?** — Is there a bootstrap state, a required initial snapshot, or does the component return a specific error?

10. **What size or format constraints exist for record description fields?** — SQLite TEXT columns are effectively unbounded; does the import validate maximum description length or character encoding (UTF-8 vs. ASCII)?

**Please review this gap list and indicate which should be addressed in the LLD now versus deferred as open questions.**