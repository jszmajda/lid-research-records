Now I'll run an LLD-level edge-case probe to identify gaps in the design that should be addressed before moving to specs.

## Phase 2 LLD-Level Edge-Case Probe

Testing the registry design against "what happens when..." scenarios:

1. **Disk space exhaustion during import** — The LLD describes temporary database creation but does not specify error handling if disk fills partway through. Does the import fail gracefully? Is the temporary file cleaned up?

2. **Corrupted snapshot file (partial transfer)** — If a snapshot arrives truncated or with a broken JSON line, does the signature verification catch it, or does import fail during schema validation?

3. **Concurrent snapshot imports** — If two snapshots arrive while one is being processed, what prevents race conditions between the temporary database and the atomic replacement?

4. **Database deleted during lookup** — If a technician is mid-lookup when the active database file is deleted, what happens? Does the lookup fail, or is there a read lock protecting the file?

5. **Crash during atomic replacement** — The LLD says "atomically replacing" the database, but what recovery happens if the kiosk loses power between deleting the old file and creating the new one?

6. **Serial number edge cases** — What if a record serial is empty, null, or contains characters that need escaping in SQL (single quotes, backslashes)? How does normalization interact with storage?

7. **First import on empty kiosk** — The LLD notes "If no database exists (fresh install), the first valid import activates it." What is the fallback if that first import fails?

8. **Snapshot metadata storage** — The LLD says snapshot date is "stored as table metadata (file's import timestamp)." Is this the file mtime, or a column in the table? How is it preserved across database resets?

9. **Field type mismatches** — The schema says records are "stored as-is" from JSON. If a future snapshot has a field as an array instead of a string, does it store anyway, or fail validation?

10. **Normalization asymmetry** — A serial is normalized (whitespace trimmed, case uppercased) before lookup, but the LLD doesn't say whether this normalized form is stored or the original is stored and normalized at query time. Which approach?

---

**Which gaps should be addressed in the LLD before proceeding to EARS specs, and which can be deferred as open questions?**