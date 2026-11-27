## Phase 2 & 3 Comprehensive Output

The record-store design is now complete with the whole-visit revisions strategy fully specified, documented, and linked.

### Updated Artifacts

1. **LLD** (`docs/intent/record-store/record-store-design.md`):
   - Submission section details the base-revision ID, complete observation state, idempotency key, and permanent retention.
   - Revision and Unresolved Work section explains application (current-match vs. stale) and competing revision creation.
   - Retrieval and Resolution sections complete the public API.
   - Key Design Decisions table links to the full decision doc.

2. **EARS Specs** (`docs/intent/record-store/record-store-specs.md`):
   - Expanded to 11 requirement lines covering submission, revision application, retrieval, and resolution.
   - Each spec is concrete and scoped; none rely on conversation context.

3. **Decision Doc** (`docs/intent/record-store/decisions/concurrent-edit-strategy.md`):
   - Full context on why the decision is needed (offline work, competing edits).
   - Decision elements: inherited gate (no silent discards), three major criteria (scientific intent, implementation burden, review workload), one moderate criterion (downstream clarity).
   - Both options analyzed in depth against all criteria, showing how whole-visit revisions trades review volume for simplicity and scientific preservation.
   - Selection explains why whole-visit revisions wins, naming the tenets and criteria it turns on, and documents the downstream obligations for tablet-sync (base-revision tracking) and review-export (revision-diff UI, unresolved exclusion).

### Consistency Check Results

| Check | Status |
|---|---|
| Coverage | ✓ All LLD behaviors specified in EARS. Three gaps below warrant your input. |
| Contradiction | ✓ No conflicting specs. |
| Implicit scoping | ✓ All specs explicitly scope their conditions. |
| Context-free reading | ✓ Each spec stands alone. |

### Three Gaps Requiring Your Input

These are design clarifications, not errors; the design is stable either way.

1. **Initial visit revision**: When a worker submits the first edit to a new visit (with no prior revisions), what base-revision ID should they provide? Recommend either a special value like `null` or `"initial"`, or the spec could accept any string and treat the first submission specially.

2. **Non-existent base-revision**: If a submission references a base-revision that was never stored (e.g., from a client that lost its local state), should the system (a) reject it, (b) treat it as stale and create a competing revision, or (c) accept it if all field validations pass? Option (a) is safest but could frustrate workers; option (c) is most permissive but could silently create orphan revisions.

3. **Resolution finality**: Once a coordinator resolves competing revisions and selects a winner, can they change their mind and re-resolve, or is that outcome immutable? Immutable is safer (one source of truth) but less flexible; mutable requires tracking multiple resolutions and rules for which one is "current."

Once you clarify these three points, the record-store design carries all the information tablet-sync and review-export need to proceed. The design doc explains the tradeoffs and downstream obligations they'll implement.