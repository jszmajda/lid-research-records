Now I'll run the Phase 2 edge-case probe to identify gaps in this LLD:

## Phase 2: LLD Edge-Case Probe

**Gaps identified in the registry design:**

1. **Snapshot date extraction and format** — The design mentions snapshot metadata contains a date, but doesn't specify: what format does it use in the JSON snapshot file, and how is it parsed and validated?

2. **Active snapshot persistence** — On startup, the component scans the directory and selects the most recent snapshot by date. But when a lookup fails (no snapshot available), you noted it returns "current timestamp." Is active-snapshot state persisted in the registry directory, or re-elected from files on every startup?

3. **Duplicate snapshot dates** — What happens if two snapshot files have the same metadata date? The design says "most recent (by snapshot date field)" but doesn't break ties (filesystem mod time, filename parse order, error).

4. **Corrupted snapshot files and recovery** — If a snapshot database file is truncated or corrupted on disk, is it skipped at startup, reported, and moved aside? What's the error handling for database open/read failures during startup vs. during a lookup?

5. **Snapshot lifecycle and cleanup** — The design builds snapshots as temporary files then atomically moves them to permanent names. But it never specifies: how many old snapshots are kept, is there a quota or cleanup strategy, or do they accumulate indefinitely?

6. **Error representation to the caller** — The lookup interface returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, but the design now adds "no snapshot available" as a third case. Is that a third enum variant, an exception, or a null/empty result?

7. **Concurrent snapshot import during lookup** — A technician might request a lookup while a new snapshot is being imported and activated. Does the lookup see a transient error, or is there a read lock that holds the old snapshot active until import completes?

8. **Normalization edge cases** — The design says "whitespace trimming and uppercase" but doesn't specify: tabs vs. spaces, leading/trailing only or internal whitespace, non-ASCII letters (unchanged), empty string after normalization (rejected or matched to nothing).

9. **Performance under pathological data** — The HLD goal is 250 ms lookup on 90K records. SQLite lookup should easily meet that, but the design doesn't note any index strategy. Is a simple PRIMARY KEY on `serial` sufficient, or does the snapshot import need to validate performance (e.g., query-plan checks)?

**Which of these should be resolved in the design before the specs are finalized?**