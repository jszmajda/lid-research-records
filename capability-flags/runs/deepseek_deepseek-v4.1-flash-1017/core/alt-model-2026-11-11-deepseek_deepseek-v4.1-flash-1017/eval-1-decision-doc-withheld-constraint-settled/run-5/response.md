Registry design is drafted with the local SQLite index selected; the stale "backend remains open" line in the HLD is also updated.

The design now covers: generation-based snapshot storage with an atomically replaced `registry/active` pointer; staging and full validation before activation; a `records` table keyed by normalized serial plus `snapshot_meta` for the snapshot date; failed imports leaving the active generation untouched; and startup recovery using the retained snapshot plus one previous generation. The backend choice is recorded as a Decisions & Alternatives row rather than a decision doc, since the HLD's no-runtime-network tenet eliminates the HTTPS and managed-service options.

Phase 2 edge probe surfaced these gaps in the LLD:

1. First-run lookup when no snapshot has ever been imported — the `Found`/`NotFound` interface has no defined result.
2. Whether rebuild-from-retained-snapshot should show progress at the kiosk.
3. Whether rebuild stages a new generation or repairs the active one in place.
4. The exact minimum free-disk threshold before staging.
5. Whether the previous generation is deleted on the next successful import or retained until manually cleared.
6. Whether an unparseable snapshot date or missing snapshot metadata rejects the import.
7. Whether a second import may start while one is already running.

Please review `docs/intent/registry/registry-design.md` and tell me which of these to settle now versus leave deferred; once approved I'll cascade to the registry EARS specs.