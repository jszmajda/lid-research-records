Now I'll run the LLD-level edge-case probe — gaps inside this component's own design, not cross-component interactions (those come in Phase 4).

**Edge-case probe for the Registry LLD:**

| # | What happens when… | Gap |
|---|---|---|
| 1 | **Power is lost between flush (step 5) and rename (step 6)?** | `registry-staging.db` exists on the filesystem but `registry.db` still names the old snapshot. Startup cleanup deletes the staging file — that's handled. But is the previous `registry.db` still coherent after the interrupted flush? If SQLite's WAL or journal file was mid-commit, the previous DB could itself be corrupt. The design doesn't address this. |
| 2 | **Two import operations run concurrently?** | Both would write to `registry-staging.db`. The second open would truncate or corrupt the first's work. No mutual-exclusion mechanism is described. |
| 3 | **`registry.db` is replaced by rename while a lookup's SQLite connection is open?** | On most OS/filesystem combos, an open file descriptor keeps the old inode alive, so the in-flight lookup finishes against the old snapshot and the new file is visible to subsequent opens. But the design doesn't state this guarantee explicitly, and behavior on Windows (where rename over an open file fails) is unaddressed. |
| 4 | **`meta` has zero rows after a crash mid-import?** | A crash between writing records and writing `meta` leaves a staging DB without the `meta` row. The startup cleanup deletes it. But if the *active* `registry.db` somehow has an empty `meta` (e.g., a prior partial activation), every lookup would fail with no clear error. The design doesn't specify what `findBySerial` does if `meta` is missing or empty. |
| 5 | **A snapshot's `record_json` field contains malformed JSON?** | The import sequence validates signature, schema version, and serial uniqueness — but not the JSON content of individual records. If the certificates component receives a malformed `record_json`, the error surfaces at certificate generation time rather than import time. The design doesn't specify whether record JSON is validated on import. |
| 6 | **The data directory is full when writing the staging file?** | The staging DB creation would fail mid-write, leaving a partial `registry-staging.db`. The design says to delete it and retain the previous snapshot, which handles this — but it doesn't say whether a partial write is distinguishable from a complete one, or how to detect it before the rename. |

---

Here is the updated LLD for your review. **Phase 2 stop.**

---

**`docs/intent/registry/registry-design.md`** — what changed:

- **Architecture**: removed "not selected yet" language; states SQLite is the lookup backend.
- **Storage Layout** (new section): two-table schema — `records` with `serial TEXT PRIMARY KEY` (pre-normalized) and `record_json`, plus a single-row `meta` table holding `snapshot_date` and `schema_version`.
- **Snapshot Import**: rewritten with the concrete staging-file sequence (write → flush → rename); stale staging file cleanup on startup.
- **Lookup Behavior**: rewritten with the parameterized SQL query and the no-snapshot-yet sentinel (flagged as a deferred decision).
- **Decisions & Alternatives** (new section): records the SQLite choice against the two network-backed alternatives, the rename-for-activation choice, and the pre-normalized-serial-as-PRIMARY-KEY choice.

---

**Edge-case probe produced six gaps** for you to triage:

1. **Prior `registry.db` coherence after power loss mid-flush** — the staging file is cleaned up, but does the surviving `registry.db` remain readable if its own WAL/journal was in flight?
2. **Concurrent import prevention** — no mutual-exclusion mechanism is described; two simultaneous imports write to the same staging file.
3. **Rename over an open file handle** — behavior when a lookup connection is open at activation time is unspecified, particularly on Windows.
4. **Empty or missing `meta` row in the active DB** — `findBySerial` behavior if `meta` is absent is undefined.
5. **Per-record JSON validation on import** — the import sequence catches structural problems but not malformed `record_json` content.
6. **Partial staging-file write from a full disk** — the design says to delete on failure but doesn't address detecting a partial write before the rename.

Which of these do you want addressed in the LLD before we move to EARS, and which should go into Deferred?