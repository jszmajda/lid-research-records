Now I'll run an LLD-level edge-case probe to identify potential gaps in the design.

**Edge-Case Probe — Registry LLD Gaps**

These "what happens when..." questions target this LLD's internal gaps:

1. **What happens when the kiosk runs out of disk space during index preparation?** The temporary database build may fail mid-write. Is there disk space validation before starting? Should there be a minimum free space check?

2. **What happens when two records have serials that normalize to the same value but differ in original form?** For example, `"ABC-123"` and `" abc-123 "` normalize to the same key. The unique index would reject the second. Should this be caught during validation as a duplicate serial error, or is it a snapshot corruption case?

3. **What happens when a lookup occurs exactly during the atomic file rename?** SQLite file locking and OS-level atomicity should handle this, but the behavior when a read handle is open to the old file during rename is unstated. Does the old handle continue working? Does the next lookup open the new file?

4. **What happens when the active database file is corrupted?** No recovery mechanism is specified. Should there be a fallback to the previous snapshot, or does corruption require a new snapshot import?

5. **What happens when the temporary database file already exists from a failed prior import?** Should import check for and delete stale `.tmp` files before starting?

6. **What happens when the metadata table is missing the `snapshot_date` key?** Lookup returns the snapshot date from metadata, but no fallback is specified if the key is absent. Should this be a fatal database corruption error?

7. **What happens when a serial number in the snapshot contains non-ASCII characters?** The normalization is ASCII-only (uppercase letters), but the spec doesn't explicitly reject non-ASCII. Should schema validation enforce ASCII-only, or should non-ASCII pass through untouched?

8. **What happens when SQLite returns an error during query execution?** Lookup behavior on database errors (locked, I/O error, corrupted page) is not specified. Should this surface as an error result, or does it need a separate error channel from `Found`/`NotFound`?

---

**Updated Registry LLD**

The registry design now includes:

- **Architecture**: SQLite as the chosen local embedded index
- **SQLite Index Preparation**: Temporary database build with atomic file replacement
- **Data Model**: Equipment table schema and metadata table for snapshot date/version
- **File Management**: Atomic rename mechanism to avoid partial index exposure
- **Decisions & Alternatives**: Four decisions documented with chosen approach, alternatives, and rationale:
  - Lookup backend (SQLite vs. HTTPS directory vs. search service)
  - Database replacement mechanism (atomic rename vs. in-place updates)
  - Normalization scope (whitespace/ASCII only vs. full Unicode)
  - Schema version storage (in-database vs. separate manifest)
- **Open Questions & Future Decisions**: Performance tuning and compression deferred

The LLD is context-free and ready for review. The edge-case probe above identifies eight gaps for you to triage — which should be addressed in the LLD now, which are spec-level concerns for Phase 3, and which are acceptable open questions.

Which gaps would you like to resolve in this LLD?