Now I'll run the LLD-level edge-case probe to identify gaps in this design.

## LLD-level Edge-Case Probe

The following "what happens when..." questions target potential gaps in the registry design:

1. **Disk space**: What happens when disk space is exhausted during database construction (step 4 of import)?

2. **Concurrent imports**: What happens if a second snapshot import is triggered while one is already in progress?

3. **Application crash during activation**: What happens if the application crashes or loses power during the filesystem rename operation (step 7)?

4. **Missing or corrupted active database**: What happens when a lookup is requested but the active database file is missing or corrupted?

5. **First-run state**: What happens when `findBySerial` is called before any snapshot has been imported?

6. **Empty snapshot**: What happens when a snapshot is cryptographically valid but contains zero equipment records?

7. **Backup file collision**: What happens if `registry.sqlite.prev` already exists when trying to save the current active database during activation?

8. **SQL injection risk**: What happens when a serial number contains SQL special characters (quotes, semicolons)? (The design uses parameterized queries, but this should be stated explicitly.)

9. **Missing bundled public key**: What happens during import if the bundled public key resource is missing from the application bundle?

10. **Malformed metadata**: What happens when the metadata table exists but is missing the `snapshot_date` or `schema_version` keys?

11. **Schema version evolution**: What happens when a future snapshot uses a newer schema version that adds fields the current code doesn't recognize? (The design rejects unsupported versions, but should we accept forward-compatible additions?)

12. **Long-running transaction**: What happens if parsing and inserting 90,000 records takes long enough that SQLite's transaction locks become a concern for concurrent reads?

**Which of these gaps should be resolved in the LLD now, and which should be deferred as implementation details or open questions?**

---

**Context-free reading check**: The updated LLD includes explicit rationale in the Decisions & Alternatives table, names the specific normalization rules, describes the complete import sequence, and specifies file paths. A reader without conversation context can follow the design. The three options are documented with their trade-offs clearly stated.