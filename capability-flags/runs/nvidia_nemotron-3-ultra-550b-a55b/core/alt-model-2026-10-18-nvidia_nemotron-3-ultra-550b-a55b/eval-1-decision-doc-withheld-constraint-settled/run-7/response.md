Now let me run **Phase 4 — Intent-narrowing edge audit** to surface cross-spec and per-spec divergences before writing tests.

## Phase 4 — Intent-Narrowing Edge Audit

### Cross-Spec & Cross-Segment Interactions

| # | Interaction | Question |
|---|-------------|----------|
| 1 | REG-005 → REG-006 | REG-005 says "build... before activating", REG-006 says "swap atomically". Is the build fully synchronous and complete before the swap begins, or can they overlap? |
| 2 | REG-007 during import | If a lookup arrives while REG-005/006 are in progress (building new DB, swapping pointer), does it block, serve stale, or error? |
| 3 | REG-008 + REG-006 | REG-008 says "leave previous snapshot's database file and active pointer unchanged". Does REG-006's "atomic swap" only occur on *success*, making REG-008 redundant, or is there a failure mode mid-swap? |
| 4 | Snapshot date source (Registry ↔ Certificates) | Certificates (CERT-001) expects `snapshotDate` in the result. Does the SQLite DB store the snapshot date per-row, or is it read from a metadata table/file at lookup time? |
| 5 | REG-001 normalization vs SQLite query | REG-001 normalizes *before* lookup. Does the SQLite query use the normalized value directly, or does the DB store normalized serial numbers? |

### Per-Spec Divergence Probes

| Spec | Divergent Readings | Fork? |
|------|-------------------|-------|
| **REG-005** "build a new SQLite database file containing all records with a primary key on serial_number" | a) Single table `records(serial_number PK, calibration_date, due_date, description, snapshot_date)`<br>b) Two tables: `records` + `metadata(snapshot_date, schema_version)`<br>c) Store raw JSON in a blob column, parse at query time | **Yes** — schema shape affects REG-004, REG-007, and snapshot date source |
| **REG-006** "swap atomically" | a) `rename(new.db, active.db)` on POSIX (atomic on same filesystem)<br>b) Update a symlink `active.db → snapshot-<date>.db`<br>c) Write `active_manifest.json` pointing to the new file; readers consult manifest | **Yes** — affects crash safety, REG-008 failure semantics, and whether readers need to re-open |
| **REG-007** "prepared statement with a bound parameter" | a) Prescriptive: implementation *must* use `sqlite3_prepare_v2` + `sqlite3_bind_text`<br>b) Descriptive: any parameterized query achieving the latency goal qualifies | **Yes** — (a) leaks implementation into spec; (b) is the EARS norm |
| **REG-008** "report a useful error" | a) Error includes: stage (signature/schema/duplicate/build/swap), record index or serial if duplicate, underlying SQLite errno<br>b) Generic "import failed" with a log file path<br>c) Error code enum imported by certificates for UI mapping | **Yes** — "useful" is context-dependent; certificates may need to surface this to the technician |

**Please resolve the forks above.** For each, confirm the intended reading or provide a narrowing edit. I'll then update the LLD and specs accordingly before Phase 5.