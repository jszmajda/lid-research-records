Now I'll run an LLD-level edge-case probe to identify gaps in the design.

## LLD Edge-Case Probe

Probing the registry design for gaps, unstated invariants, and unspecified behavior:

1. **Concurrent lookup during import**: What happens if a technician calls `findBySerial()` while a snapshot import is in progress (after records are inserted but before activation)? Does the query block, return stale data, or error?

2. **First launch behavior**: Before any snapshot is imported, what does `findBySerial()` return? There's no active snapshot yet, so returning `NotFound(snapshotDate)` requires a snapshot date that doesn't exist.

3. **Disk space exhaustion during import**: If the disk fills up while inserting records into the `records` table (step 4 of import), does SQLite transaction rollback occur automatically, or does the kiosk need explicit cleanup? What error message does the technician see?

4. **Empty snapshot**: If a valid snapshot contains zero records (edge case: inventory team exports an empty file), does import succeed? Would queries work correctly with an active snapshot that has no associated records?

5. **Date format validation**: The design mentions `calibration_date`, `due_date`, and `snapshot_date` are stored as `TEXT`, but doesn't specify their format or whether they're validated during import. If a record has `calibration_date: "invalid"`, does import fail or succeed?

6. **Schema creation failure**: The design says "kiosk creates the file and schema on first launch if it does not exist." What happens if schema creation fails (permissions issue, disk full)? Does the kiosk crash, retry, or show an error?

7. **Activation transaction failure**: If the atomic activation transaction fails (step 5), what error is surfaced? Does the kiosk need explicit rollback, or does SQLite handle it?

8. **Duplicate serial across snapshots**: Validation checks duplicates *within* a snapshot, but the same serial number will legitimately appear across multiple snapshots (same equipment, updated dates). Is this handled correctly, or does the design need to clarify that duplicates are only invalid within one snapshot?

9. **Public key loading**: The design says "bundled Ed25519 public key embedded in the kiosk binary" but doesn't specify how it's accessed at runtime. Is it a byte array constant, read from a file, or retrieved from a resource?

10. **Normalization boundary**: Serial normalization uppercases "ASCII letters" but leaves "punctuation significant." What happens if a serial contains non-ASCII Unicode letters (e.g., "Café-123")? Are they normalized, rejected, or passed through?

11. **SQLite file corruption recovery**: If `registry.db` becomes corrupted (power loss, disk failure), what's the recovery path? Does the kiosk detect corruption on startup and recreate the schema, or does it surface an error requiring manual intervention?

12. **Snapshot cleanup timing**: After activation, "delete rows from `snapshots` and `records` for snapshots older than the previous one." Does this happen in the same transaction as activation, or as a separate cleanup step? If cleanup fails, does it leave orphaned data?

---

**Which of these gaps should be addressed in the LLD now, and which should be deferred as open questions?**