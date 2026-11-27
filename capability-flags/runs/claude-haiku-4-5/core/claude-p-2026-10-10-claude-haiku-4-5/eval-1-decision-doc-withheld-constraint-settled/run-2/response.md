Now I'll run an LLD-level edge-case probe to surface any gaps in the design:

## LLD-Level Edge-Case Probe

Looking at the registry design for gaps, state transitions, invariants, and error shapes:

**1. Snapshot date persistence and format** — The design references "snapshot date" in lookup results and import success messages, but does not specify its format (ISO 8601? Unix timestamp?), timezone handling, or storage in the index schema. When a lookup returns `NotFound(snapshotDate)`, is the technician shown a formatted date, or a raw value? How does the system represent a snapshot from 2023-06-15 vs. 2023-06-15T14:30:00Z?

**2. Schema version mismatch error reporting** — The design states "reject unsupported schema versions" but does not specify: which schema versions are currently supported? What error message or code is shown to the technician when a newer snapshot arrives? Can a kiosk roll forward to a new schema version, or are snapshots locked to a specific version per kiosk build?

**3. File permissions and atomic swap safety** — The design describes a staging file and atomic activation. On filesystems that do not guarantee atomic rename semantics (certain network mounts, or if the kiosk unexpectedly loses power during the swap), what happens to the index consistency? Is there any mechanism to detect or recover from a partially-swapped state?

**4. Normalization of non-ASCII input** — The design specifies "uppercase ASCII letters" but does not state what happens with accented characters (é, ñ), CJK input, emoji, or other Unicode. Does the system silently strip non-ASCII, error out, or pass them through? Do serial numbers in the snapshot ever contain non-ASCII characters?

**5. Concurrent import and lookup race** — If a technician queries while an import is underway, the design relies on the staging file to prevent partial reads. But if the OS file cache has the old `registry.db` open in memory, and the import does an atomic rename, is the running query's file handle still valid, or does it error?

**Recommendation:** These gaps are worth clarifying before writing tests, since they affect error handling paths and schema stability. Which of these would you like to close in the LLD now, and which can defer as implementation questions?

---

**STOP for Phase 2 user review.** The updated registry LLD fleshes out the local SQLite index approach, documents the schema and file paths, adds a Decisions & Alternatives table recording the backend choice, and marks recovered questions as deferred. Please review the design and the edge-case probe above. Would you like to:

1. Revise any sections of the LLD?
2. Close specific edge-case gaps now?
3. Proceed to Phase 3 (EARS spec draft) with these questions noted as open?