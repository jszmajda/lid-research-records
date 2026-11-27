Here is the updated registry design, followed by the edge-case probe.

---

## Registry Design — Phase 2 draft

The LLD is now at `docs/intent/registry/registry-design.md`. The substantive additions over the previous draft:

**Index Schema** — two tables: `records` (`serial_normalized TEXT PRIMARY KEY`, `description`, `calibration_date`, `due_date`) and `snapshot_meta` (one row, `snapshot_date`). Normalized serials stored at import time so the primary key index covers every lookup.

**Snapshot Import** — builds to a temp file in the same directory, then atomically renames over the active path. Fresh-kiosk first-import is called out explicitly.

**Lookup Behavior** — normalize the caller's serial (trim + uppercase ASCII, leave punctuation), query `records` by `serial_normalized`, read `snapshot_meta` in the same connection, return `Found` or `NotFound`.

**Decisions & Alternatives** — records four decisions: backend choice (SQLite, because the HLD's offline-only tenet rules out both network-dependent options), atomic activation (rename over active path), normalization timing (at import + at query), and snapshot date placement (single `snapshot_meta` row).

---

## LLD-level edge-case probe

Questions pointed at gaps inside this component's own spec — cross-spec interactions come at Phase 4, not here:

1. **Concurrent imports.** The LLD says "build to a temp file, then rename." If two import operations run at the same time, they could both write to the same temp file path and race on the rename. Does the component need to serialize imports, or produce unique temp filenames?

2. **Partial read of `snapshot_meta`.** If a lookup connection opens after the rename but before `snapshot_meta` is populated (i.e., the write was not fully committed to the file before rename), what does `findBySerial` return? The LLD implies a single atomic build step, but it doesn't state that `snapshot_meta` must be populated before activation completes.

3. **NULL field values.** A record in the snapshot might have a missing `calibration_date` or `due_date`. The schema uses `TEXT` with no `NOT NULL`. Does `Found(record, snapshotDate)` permit null date fields in the result type, or does the import step reject records with missing required fields?

4. **Empty-string serial.** The normalization rule (trim + uppercase) applied to an empty string or whitespace-only string produces an empty string. Does `findBySerial("")` return `NotFound` or is it an error? The boundary isn't specified.

5. **Temp file on a different mount.** If the application data directory and the temp file are on different filesystems, `rename()` fails non-atomically on some platforms. The LLD doesn't constrain where the temp file is written; "same directory" is the rule, but it isn't stated as a hard requirement enforced by the implementation.

6. **Import error reporting contract.** The LLD says "reports a useful error to the caller" on failure. The shape of that error (type, fields, whether it distinguishes signature failure from schema version failure from duplicate serial) isn't specified.

7. **Snapshot with zero records.** A valid, correctly signed snapshot containing no records is technically not excluded. Is an empty snapshot a valid activation target, or should it be rejected?

---

**Questions for you:**

- On gap 3 (NULL date fields): should the import step enforce that `calibration_date` and `due_date` are present and non-empty, or should the result type allow nulls?
- On gap 7 (zero-record snapshot): valid or reject?
- Any of the other gaps you'd like to close in the LLD now, or defer to Open Questions?

Once you've reviewed and approved (with or without edits), we'll move to Phase 3 — the EARS spec update.