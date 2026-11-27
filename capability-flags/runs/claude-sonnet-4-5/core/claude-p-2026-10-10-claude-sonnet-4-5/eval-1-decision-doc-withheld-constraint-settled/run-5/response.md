Now I'll run an edge-case probe on this LLD to identify potential gaps.

**LLD-Level Edge-Case Probe:**

1. **What happens when** a snapshot import is interrupted mid-process (power loss, crash) — is the temporary database file cleaned up on next startup, or does it accumulate orphaned files?

2. **What happens when** the atomic rename fails (disk full, permissions issue) — does the error message distinguish between validation failures and filesystem failures?

3. **What happens when** two processes attempt concurrent imports — is there file locking to prevent race conditions on the temporary filename or active database path?

4. **What happens when** the active database file exists but the metadata table is missing or corrupt — does lookup fail immediately, or attempt recovery?

5. **What happens when** a serial number in the snapshot contains characters outside ASCII (Unicode, special symbols) — is the normalization rule (trim + uppercase ASCII) specified for non-ASCII handling, or does it silently drop/transform them?

6. **What happens when** the equipment table contains a row with NULL in a NOT NULL column due to database corruption — does the query fail, skip the row, or surface a specific error?

7. **What happens when** a lookup is in progress when the active database file is replaced — does the ongoing query complete against the old file (file handle still open), or does it fail?

8. **What happens when** the snapshot date is malformed or missing from the metadata table — does `findBySerial` return an error, use a sentinel value, or derive it from the filename timestamp?

9. **What happens when** the data directory doesn't exist at import time — is it created automatically, or does import fail with a clear error?

10. **What happens when** the signature verification step needs to handle multiple bundled public keys (key rotation scenario) — is this considered out of scope, or should the design note it as a future concern?

**STOP — Please review the updated registry LLD and this edge-case probe. Which gaps should be addressed in the LLD now, and which should be deferred as open questions?**