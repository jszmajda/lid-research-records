Now I'll run an LLD-level edge-case probe to identify gaps and surface questions for triage.

## LLD-Level Edge-Case Probe

**Gaps and clarification questions specific to the registry component's SQLite design:**

1. **Index corruption detection**: When the active `index.db` file is corrupted or unreadable, how does the system recover? Should it fall back to parsing the raw snapshot file, automatically delete the corrupted index, or report an error to the technician?

2. **Serial normalization edge cases**: How are non-ASCII characters in serial numbers handled? Should accented characters, Unicode, or other non-ASCII input be rejected, passed through, or normalized in some way?

3. **Partial metadata**: If the `metadata.json` file is missing or unparseable while the index exists, should the lookup still work (returning results without a snapshot date), or should it fail?

4. **Staging directory cleanup**: If the system crashes during import (staging directory is half-populated), how is it detected and cleaned up on the next startup? Should there be a recovery mechanism that detects stale staging directories?

5. **Snapshot date representation**: Is the snapshot date format fixed (ISO 8601, epoch, other)? Should it be validated during import? How is it displayed to the technician?

6. **Empty snapshots**: Is a snapshot with zero records valid? Can the index be empty?

7. **Record field lengths**: Are there maximum length constraints on calibration date, due date, and description fields? Should the import reject records with unexpectedly large fields?

8. **Concurrent access**: Can multiple kiosks update from the same USB at the same time, or is concurrent import ruled out by the single-kiosk design? If concurrent, how is the staging directory protected?

9. **Import rollback**: After a snapshot is activated, is there a way to roll back to a prior snapshot, or is "previous snapshot preserved on failure" the only retention mechanism?

10. **Snapshot versioning**: The LLD mentions "reject unsupported schema versions"—what schema versions are supported, and how is a future version change handled (do older kiosks gracefully refuse, or is there a migration path)?

---

**Which gaps should be fixed in the LLD before proceeding, and which can be deferred as open questions?** I recommend deferring 4, 6, 7, 8, and 10 as implementation questions to be resolved during Phase 5 (tests); addressing 1, 2, 3, 5, and 9 in the LLD now will clarify intent before tests are written.

**STOP for user review**: Please review the completed registry design and indicate which gaps to address, whether the SQLite approach is the right level of detail, and whether you're ready to proceed to Phase 3 (EARS specs update).