Now I'll run an LLD-level edge-case probe to identify any gaps in the design.

**Edge-Case Probe for Registry LLD:**

1. **Concurrent lookup during activation** — What happens when a lookup is in progress while snapshot activation closes and replaces the database file?

2. **Insufficient disk space** — What happens when preparing the new database fails because the kiosk has less than 150 MB free?

3. **File permission errors** — What happens when the application cannot write to the data directory or rename files due to permissions?

4. **Ambiguous startup state** — What happens if both `active.db` and `import-staged.db` exist when the application starts (crash during activation)?

5. **Schema version migration** — The design mentions rejecting "unsupported" schema versions, but what happens when a supported-but-newer schema version needs data transformation before import?

6. **Empty valid snapshot** — What happens when a snapshot has valid signature and schema but contains zero records?

7. **Snapshot date format and validation** — What format does the snapshot date use (ISO 8601? Unix timestamp?)? What happens if it's missing or malformed in the snapshot?

8. **Database file corruption after activation** — What happens if `active.db` becomes corrupted between successful activation and the next lookup (storage failure)?

9. **SQL injection via serial numbers** — What happens if a serial number contains SQL special characters like single quotes or backslashes?

10. **Maximum serial number length** — What's the maximum length for a serial number field, and what happens if a snapshot record exceeds it?

11. **Snapshot date timezone** — Does the snapshot date include timezone information, and if so, how is it displayed on certificates?

Which gaps should be addressed in this LLD revision versus deferred as implementation details?

**STOP for user review.**