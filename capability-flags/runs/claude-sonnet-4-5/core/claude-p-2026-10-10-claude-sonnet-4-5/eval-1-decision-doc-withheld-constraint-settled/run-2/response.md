I've completed the registry LLD expansion with the SQLite choice documented. Here's the updated design:

## Updated Registry LLD

The LLD now includes:

**Architecture**: Embedded SQLite database with local index construction and predictable lookups.

**SQLite Schema**: 
- `equipment` table with indexed serial numbers
- `snapshot_metadata` table for snapshot date
- Normalized lookup using `UPPER(TRIM(...))` on serial numbers

**Database File Management**: Atomic file swap strategy - imports write to a staging path, then atomically replace the active database only after successful validation.

**Decisions & Alternatives table**: Documents the choice of SQLite over HTTPS directory and managed search service, with rationale that it provides predictable local lookups matching the HLD tenet.

## Edge-Case Probe Results

The LLD probe surfaced 32 questions about under-specified behaviors. Key categories:

**State Transitions** (Questions 1-4):
- Lookup behavior during import operations
- Concurrent import handling  
- Crash recovery between staging and swap
- First import on fresh kiosk

**Unstated Invariants** (Questions 5-9):
- SQLite concurrent reader guarantees
- File system atomicity guarantees (rename vs. symlink)
- Bundled public key format and location
- Disk space assumptions
- Schema version format

**Unspecified Error Shapes** (Questions 10-15):
- Corrupted active database handling
- Specific signature verification errors
- Duplicate serial number error messages
- Missing/malformed snapshot date handling
- Date field validation
- Staging file creation failures

**Ordering Assumptions** (Questions 16-19):
- Exact swap operation sequence
- Snapshot date lookup failure handling
- Transaction commit vs. swap failure handling
- "Readable" confirmation definition

**Resource Cleanup** (Questions 20-24):
- Failed import staging file cleanup
- Open database handle behavior during swap
- In-flight query behavior during swap
- Old database retention policy
- Old database removal failure handling

**Boundary Conditions** (Questions 25-32):
- Empty snapshot handling
- Maximum size limits
- Empty/whitespace-only serial numbers
- Normalization creating duplicates
- Empty field values
- NULL/missing fields
- Lookup before first import

**Which gaps should be resolved in the LLD now vs. deferred?** Please indicate which questions warrant immediate specification and which can remain open for implementation-time decisions.