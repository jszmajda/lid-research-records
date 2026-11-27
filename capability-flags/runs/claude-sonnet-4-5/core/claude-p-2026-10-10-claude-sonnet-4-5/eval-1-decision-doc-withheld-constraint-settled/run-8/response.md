Now I'll run an LLD-level edge-case probe to identify any gaps in the design before we proceed.

**Edge-case probe for Registry LLD:**

1. **What happens when** the temporary database file already exists from a previous failed import attempt?
2. **What happens when** the atomic file rename fails due to filesystem permissions or disk space?
3. **What happens when** a lookup is requested while a snapshot import is in progress?
4. **What happens when** the active SQLite database file becomes corrupted (disk failure, power loss)?
5. **What happens when** normalized serial numbers from different original inputs collide (e.g., "ABC-123" and "abc 123" both normalize to "ABC123")?
6. **What happens when** the snapshot contains records exceeding SQLite's limits (row count, database file size)?
7. **What happens when** a serial number lookup contains characters that need SQLite escaping?
8. **What happens when** multiple import operations are triggered in rapid succession?

---

## Updated Registry LLD (Phase 2)

Here's the completed registry design incorporating the local SQLite index:

### Key changes:
- **Architecture** updated to specify embedded SQLite as the chosen backend
- **SQLite Index Structure** section added describing the two-table schema
- **Index Rebuild Process** section added with 8-step import sequence
- **Lookup Behavior** updated to reference SQLite query mechanism
- **Decisions & Alternatives** table added documenting the SQLite choice and its rationale against the other options
- **Open Questions** section added (currently resolved)

The design now specifies:
- Atomic file-level replacement for import atomicity
- Synchronous rebuild during import (no background jobs)
- Single-file database with indexed primary key for 250ms lookups
- Normalized serial numbers as the lookup key
- Read-only connections after import completes

**Please review the edge-case questions above.** Which gaps should be addressed in this LLD, and which can be deferred? Once you've triaged these, I'll update the design accordingly before moving to Phase 3 (EARS specs).