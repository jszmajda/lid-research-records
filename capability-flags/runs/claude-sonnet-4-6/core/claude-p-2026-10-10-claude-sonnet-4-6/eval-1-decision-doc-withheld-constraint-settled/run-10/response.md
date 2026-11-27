Here is the updated registry LLD, followed by the edge-case probe.

---

## Phase 2 — Registry LLD (updated)

**`docs/intent/registry/registry-design.md`**

The backend is now fully specified as a local SQLite index. Key additions:

- **Two-table schema**: `snapshot_meta` (one row, holds the snapshot date) and `registry_records` (one row per record, keyed on the normalized serial number).
- **Atomic activation**: import writes to a staging file, renames it over the active file in one operation. The active file is never touched until the full import succeeds. A leftover staging file from a prior crash is deleted at the start of the next import.
- **Connection lifecycle**: lookup opens a read-only connection per request; import opens a read-write connection to the staging file and closes it before the rename. No connection spans the rename.
- **First-launch behavior**: before any import, `findBySerial` returns `NotFound` with an absent snapshot date.
- **Decisions & Alternatives**: records the SQLite choice and why the HTTPS-directory and managed-service candidates were set aside.

---

## LLD-level edge-case probe

Gaps inside this LLD that specs don't yet address:

1. **Corrupted active file**: if the active SQLite file is corrupted (disk error, truncated write), a lookup attempt will fail with a database error, not a clean `NotFound`. The LLD has no recovery path for this state — no fallback, no diagnostic. What should happen?

2. **Rename atomicity on the kiosk filesystem**: POSIX `rename()` is atomic; on Windows with FAT or exFAT (possible for a production-area kiosk), it is not. If the kiosk OS or filesystem doesn't guarantee an atomic rename, the activation step can leave a partially-written active file visible to concurrent lookups. Is the kiosk filesystem POSIX-rename-safe, or does activation need a different mechanism?

3. **Schema version list**: the import rejects unsupported schema versions, but the LLD defers the version list to an open question. If two snapshot schema versions are both valid (e.g., v1 and v2 with different record fields), do both map to the same `registry_records` schema, or does the table shape differ by version? This needs to be closed before EARS can specify import rejection precisely.

4. **`serial_original` when multiple raw forms normalize to the same key**: the uniqueness check operates on normalized serials, so two records with the same normalized serial but different punctuation are caught as duplicates. The LLD implies `serial_original` is the form from the snapshot — but if the snapshot itself somehow has two records that normalize to the same key but with different originals, the duplicate check catches that before either is written. This edge is covered by REG-003. Worth confirming the probe didn't miss a gap here, but I believe it's closed.

5. **`snapshot_meta` consistency with `registry_records`**: both tables are written in the same staging database and renamed atomically, so they are always consistent. But the LLD doesn't state they share the same transaction — it says "all records are written and validated" before rename. Should the final write of `snapshot_meta` and the last batch of `registry_records` be committed in a single SQLite transaction to rule out a partial staging file?

Items 1, 2, and 3 are genuine gaps; 5 is a clarification worth resolving in the LLD before specs are written. Item 4 appears closed.

---

Which of these gaps do you want to address in the LLD now, and which should go to the Deferred list? And does anything in the LLD read differently than you intended?