Now I'll run an LLD-level edge-case probe to identify gaps in the registry design:

## LLD-Level Edge-Case Probe

The following questions target gaps in the registry component's internal behavior:

1. **Missing or corrupted database on startup** — What happens when the kiosk starts and no SQLite file exists, or the file is corrupted? Does `findBySerial` return an error, or is there a bootstrap state?

2. **Concurrent import and lookup** — What happens when a snapshot import starts while lookups are in progress? Are ongoing lookups blocked, failed, or do they continue reading the old snapshot?

3. **Failed atomic replacement** — What happens when the database file replacement (the atomic swap from temporary to active) fails partway? Does the old snapshot remain readable?

4. **Simultaneous imports** — What happens when two snapshot imports are triggered at the same time (e.g., technician inserts USB while another import is validating)?

5. **Disk full during index build** — What happens when disk space runs out while building the temporary database? Does the error surface clearly enough to diagnose?

6. **Malformed record dates** — What happens when a record's calibration or due date is malformed or missing in the snapshot JSON? Reject the entire snapshot, skip the record, or accept with a sentinel value?

7. **Empty normalized serial** — What happens when normalization reduces a serial number to an empty string (e.g., input was only whitespace)?

8. **Validation-to-activation ordering** — What ordering constraint must hold between signature validation, schema validation, duplicate detection, and index build? Can any steps run in parallel?

9. **"Last valid snapshot" invariant** — What ensures the "last valid snapshot remains active on import failure" guarantee? Is there a state where no snapshot is active?

10. **Import error detail** — When import fails during validation or index build, what error information is returned? Does it distinguish signature failure from schema mismatch from duplicate serials?

**STOP for user review.** Please triage which gaps should be resolved in the LLD now versus deferred as open questions.