Good. Now I'll run the LLD-level edge-case probe before presenting for review.

---

**Phase 2 stop — Registry LLD for review**

Here is the updated `docs/intent/registry/registry-design.md`:

---

**Registry**

**Context and Design Philosophy**

Technicians enter a serial number and need calibration date, due date, and equipment description. The registry accepts signed USB snapshots, validates them, builds a local SQLite index, and exposes a single lookup interface to the certificate component.

The lookup backend is local embedded SQLite. This satisfies the HLD tenet prohibiting runtime network access, requires no running service, and gives sub-millisecond query performance at 90,000 records.

**Public Interface**

`findBySerial(serial)` → `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Certificate component uses only this interface; no direct storage access. When no snapshot has ever been imported, returns `NotFound` with a distinct no-snapshot indicator (different from "record not found in an active snapshot").

**Index Schema**

`records` table: `serial` TEXT PRIMARY KEY (normalized), `description`, `calibration_date`, `due_date`. `snapshot_meta` table: one row, `snapshot_date`. Covering index on `records.serial`.

**Snapshot Import**

1. Verify signature against bundled public key.  
2. Reject unsupported schema versions.  
3. Check serial uniqueness across the snapshot.  
4. Write all records to a temporary SQLite file.  
5. Atomic rename: temp → active path.  
6. On any failure: discard temp file; active file untouched.

**Lookup Behavior**

Strip surrounding whitespace, uppercase ASCII letters; leave punctuation unchanged. Query normalized `records.serial`. Both result variants include `snapshot_date`.

**Decisions & Alternatives**

| Decision | Chosen | Alternatives | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite | HTTPS directory; managed search service | Both alternatives require runtime network access — prohibited by HLD tenet. SQLite also needs no running service. |
| Atomic activation | Rename temp → active path | In-place overwrite; two-file pointer | Rename is filesystem-atomic on target platforms; simplest way to prevent partial exposure. |
| Normalization point | At lookup time | At import time | Keeps stored serials matching source snapshot and certificates; avoids silent import transform. |

**Open Questions / Deferred**

1. SQLite journal mode (WAL vs. default): relevant if lookup and import can run concurrently; defer to implementation.
2. No-snapshot sentinel value: exact representation in `NotFound` when no snapshot has ever loaded; defer to Phase 6.
3. Disk-full behavior during temp-file write: import fails with error; message unspecified.

---

**Edge-case probe — gaps found in this LLD:**

1. **Corrupted active SQLite file.** If the active file is corrupted (power loss after rename, disk error), `findBySerial` has no described fallback. Should it return an error, or behave as if no snapshot is loaded?

2. **Empty snapshot (zero records).** The LLD validates for duplicates and signature but does not say whether a snapshot with no records is accepted or rejected. A valid zero-record snapshot would wipe all lookups.

3. **Snapshot with valid signature but `snapshot_date` missing or malformed.** Step 1 passes, but the `snapshot_meta` write step has nothing to store for the date. Unspecified.

4. **Import attempted while a lookup is in flight.** The atomic rename is filesystem-level, but an open SQLite connection during rename may behave differently on Windows vs. POSIX. Worth confirming target kiosk platform or addressing in the journal-mode deferral.

5. **Partial USB read.** A snapshot file that is truncated (USB removed mid-copy) would fail signature verification (step 1), which is the right outcome — but this path isn't explicitly named. Low risk, but worth confirming the signature check is the right catch rather than adding a separate length/hash check.

---

Please review the LLD and the probe list. For each probe item, let me know whether to fix it in the LLD now, add it to Deferred, or leave it as out of scope. When you're satisfied with the LLD, I'll move on to Phase 3 (EARS spec update).