Phase 2 LLD draft is ready at `docs/intent/registry/registry-design.md`. I also refreshed the HLD architecture line that still said the registry backend was open.

The design now specifies:

- Local embedded SQLite index, bundled with the kiosk app; no service or network dependency.
- Import validates signature, schema version, and duplicate serials on the same normalized key used by lookup.
- A replacement is built into a staging SQLite file and activated by atomic rename, so the previous snapshot stays active on any failure.
- Index schema: `metadata` for `snapshot_date` and schema version; `records` keyed by normalized `serial_key`.
- Each lookup opens a read-only connection, reads the active snapshot date, and performs a primary-key lookup.
- Decisions recorded for lookup implementation, activation method, duplicate testing, and read model; rejected network-backed options are tied to the HLD no-network tenet.

Before I move to EARS specs, here is the LLD-level edge-case probe. Please tell me which to fold into the LLD and which to defer:

1. Concurrent imports: what prevents one import from treating another's staging file as stale or racing the rename?
2. Snapshot file changes between validation and index build: is the indexed byte stream the same one that was verified?
3. No active index yet, or a missing/corrupt active file: does lookup return `NotFound`, an error, or fail?
4. SQLite sidecars (`-wal`, `-shm`, `-journal`): what happens to them when only the main file is renamed?
5. `metadata` invariants: what if `snapshot_date` is missing, duplicated, or there are zero/multiple rows?
6. Import error shape: what exactly does the caller receive, and are stage identifiers stable?
7. Null, empty, or whitespace-only input: `NotFound` or validation error, and can normalization produce an empty key?
8. Record-level schema validation: are missing/malformed fields, wrong types, or unknown fields whole-snapshot failures?
9. Zero-record snapshots, malformed snapshot dates, or older-than-active snapshots: what activates?
10. Power-loss ordering: after the staging commit but during rename, is the previous index guaranteed intact and the new one never half-visible?
11. Normalization details: which whitespace characters, how is non-ASCII handled, and are embedded spaces/newlines significant?
12. Signature coverage: does the signature cover raw bytes or parsed records, and can a valid signature coexist with a mismatched record set?
13. Index schema upgrades: what happens when the active index was built by an older private schema after an app upgrade?

Reply with the numbers to fix vs. defer, and whether the LLD is approved as drafted.