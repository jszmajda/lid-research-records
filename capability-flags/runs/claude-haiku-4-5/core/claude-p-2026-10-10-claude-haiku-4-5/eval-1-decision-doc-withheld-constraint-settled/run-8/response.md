Now I'll run the LLD-level edge-case probe as specified in the skill. This identifies gaps and assumptions in the design that need clarification:

**LLD-Level Edge-Case Probe for Registry Design**

1. **Corrupted active database at startup**: If the active database file exists but SQLite cannot open it (corruption, truncation), does the component attempt recovery with the prior snapshot's database, or fail the entire registry component at startup?

2. **Corrupted database mid-query**: If the database becomes unreadable during an active lookup (file deletion, corruption, permissions change), should the lookup catch this and return an error with a specific code, or attempt to fall back to a prior snapshot's database in real-time?

3. **Disk space exhaustion during snapshot import**: If the kiosk runs out of disk space while building the new database in the temporary location, is the temporary file automatically cleaned up, and does the system report a "no space available" error that distinguishes it from validation failures?

4. **Snapshot schema evolution**: The current design expects a fixed JSON schema (serial, calibration date, due date, description). If a future snapshot arrives with additional fields, optional fields, or a different schema version number, should the import reject it, accept it and ignore unknown fields, or defer to the HLD's schema versioning guidance?

5. **Serial number uniqueness at insertion time**: The design validates uniqueness before index creation, but if two records have identical normalized serials (e.g., "ABC-123" and "abc-123" both normalize to "ABC-123"), how should the import handle the collision? Reject the entire snapshot, keep the first, keep the last, or insert both and let lookup return one arbitrarily?

6. **Prior snapshot cleanup**: When a new snapshot is activated, should the prior snapshot's database file be deleted immediately, retained as a fallback indefinitely, or cleaned up on a schedule? How many generations of prior databases should the component keep?

7. **Concurrent import and lookup**: If a lookup request arrives while an import is in progress, does it block until the import completes, use the old database while the new one is being built, or return an error indicating the registry is temporarily unavailable?

8. **Index file location on network storage**: If a kiosk's local storage includes a network share mounted at a path the component uses, does the design assume the network share is always available, or should it enforce index storage only on physically local media?

9. **Atomic file replacement on Windows vs. POSIX**: The design says "atomically replace" the active database file. On Windows, moving a file over an existing file in use may fail; should the component use a rename-temp-file-to-active pattern, or implement a platform-specific swap strategy?

**These gaps will be triaged in Phase 4 (intent-narrowing edge audit) after the LLD review.**

---

## Phase 2 Stop: LLD Review

I have completed Phase 2 (LLD check/draft) for the registry component:

**What was updated:**
- **Architecture section**: Expanded to describe the local SQLite index strategy in detail, including the rationale for this choice over network-based and managed-service alternatives
- **Snapshot Import section**: Detailed the four-phase process: Validation → Index Preparation → Atomic Activation → Cleanup
- **Lookup Behavior section**: Specified normalization rules and query semantics
- **Index Storage and Access section**: Defined persistence, startup behavior, fallback strategy, and access patterns
- **Decisions & Alternatives table**: Recorded the lookup backend choice with full rationale and alternatives considered
- **Open Questions section**: Listed three deferred decisions for later refinement

**Edge-case probe**: Nine gap questions identified above, ready for triage.

**Please review the updated registry design** at `docs/intent/registry/registry-design.md` and confirm:
1. Does the SQLite strategy align with your intent?
2. Are the snapshot import steps clear and complete?
3. Do the fallback and startup behaviors match your expectations?
4. Which of the nine edge-case probe questions should be resolved in the LLD now vs. deferred to implementation?

Once you approve, I'll proceed to **Phase 3** (EARS spec draft/update) to detail the behavioral requirements for the lookup and import flows.