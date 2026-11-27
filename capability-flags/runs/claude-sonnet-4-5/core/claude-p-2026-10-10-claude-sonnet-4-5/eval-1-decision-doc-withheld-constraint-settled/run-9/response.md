Now I'll run an LLD-level edge-case probe to identify gaps in the design.

## LLD-Level Edge-Case Probe

Here are "what happens when..." questions targeting gaps in the registry design:

**Database State & Schema**
1. What happens when `registry.db` exists but has the wrong schema (missing tables or columns)?
2. What happens when `registry.db` exists but is corrupted or not a valid SQLite database?
3. What happens when the database file is locked by another process during lookup?

**Import Process**
4. What happens when `registry-incoming.db` already exists from a failed prior import attempt?
5. What happens when two snapshot imports are attempted simultaneously (e.g., technician inserts USB twice)?
6. What happens when a lookup is performed while a snapshot import is in progress?
7. What happens when the snapshot is larger than available disk space, discovered partway through the index rebuild?
8. What happens when the atomic rename fails (e.g., filesystem doesn't support atomic rename)?

**Input Validation**
9. What happens when the serial number contains only whitespace or becomes empty after normalization?
10. What happens when record fields (`calibration_date`, `due_date`, `description`) are missing, null, or empty strings in the snapshot?
11. What happens when the snapshot date is missing, null, or in an unexpected format?
12. What happens when a record's serial number is valid but one of its other fields exceeds expected length limits?

**Edge Data Scenarios**
13. What happens when a serial number contains SQL special characters or SQLite injection patterns?
14. What happens when a snapshot contains zero records (valid but empty)?
15. What happens when the snapshot schema version is *newer* than what the kiosk supports (forward compatibility)?

Which of these gaps should be addressed in the LLD now, and which should be deferred as open questions?