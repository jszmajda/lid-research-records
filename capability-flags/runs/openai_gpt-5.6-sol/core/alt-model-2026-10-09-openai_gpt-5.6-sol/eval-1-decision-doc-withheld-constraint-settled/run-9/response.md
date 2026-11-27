The Phase 2 registry design now selects a per-kiosk SQLite index and defines staged construction, normalized unique keys, atomic activation, startup recovery, bounded-memory indexing, and private parameterized lookups. I also removed the stale “backend remains open” statement from `docs/high-level-design.md`.

The edge-case probe found decisions that should be settled before updating the EARS specs:

1. What should `findBySerial` return before the first valid import or when the active index is corrupt or unreadable? The current `Found | NotFound` interface cannot represent registry unavailability. Adding `Unavailable` would require a later, explicitly approved cascade into the certificates design.
2. Should imports reject snapshots with an older date, the same date but different contents, or a future date?
3. Should the registry copy the snapshot into kiosk-controlled staging before verifying and indexing it, so USB removal or modification cannot change the verified bytes?
4. Should kiosks retain the superseded index for corruption recovery, or only retain the currently active index?
5. Should a second import request be rejected while an import is running, or queued?
6. What storage headroom must be required for the active index, staged index, snapshot, and SQLite temporary files?
7. Which serial-number and snapshot-date constraints should be enforced, including empty normalized serials, control characters, length limits, date format, and manifest record-count mismatches?

Please review `docs/intent/registry/registry-design.md` and answer these numbered points, or identify which should remain deferred. I’ll stop here at the Phase 2 boundary before revising the registry specifications.