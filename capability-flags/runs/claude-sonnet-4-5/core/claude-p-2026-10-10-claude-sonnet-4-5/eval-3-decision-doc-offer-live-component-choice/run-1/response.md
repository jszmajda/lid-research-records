I've updated the record-store design with the whole-visit revisions choice and completed the deferred contract work. Here's what changed:

## Updated Design

**File**: `/docs/intent/record-store/record-store-design.md`

**Added sections**:
- **Concurrency Model**: Defines whole-visit revision semantics
- **Submission Envelope**: Visit ID, idempotency key, base revision ID, author, payload
- **Current State Representation**: Three states (Clean, Unresolved, Resolved)
- **Unresolved Work**: Format for competing revisions
- **Resolution Operations**: How coordinators resolve conflicts
- **Downstream Contract Obligations**: What tablet-sync and review-export now need to implement
- **Decisions & Alternatives**: Records the choice and rationale

**Removed**: "Open Design Choice" section

**Also updated** `/docs/high-level-design.md` to reflect the completed choice.

## Edge-Case Probe Findings

The probe identified these gaps in the current design:

**State transitions**:
- What are the competing revisions after Resolved→Unresolved transition? (new submission vs resolved revision, or re-compete all prior contributing revisions?)
- Can resolution be submitted for a Clean-state visit?
- Resolution timing relative to concurrent new submissions?

**Invariants**:
- Can base revision ID point to a contributing (non-result) revision from a prior resolution?
- Idempotency key scope: visit-scoped, author-scoped, or globally unique?
- Revision ID scope: global or per-visit?

**Error responses** (unspecified):
- Base revision ID exists but for different visit vs. doesn't exist
- Idempotency key reuse with different payload (what counts as "identical"?)
- Contributing revision IDs validation failures (mixed valid/invalid)
- Field validation vs plot reference validation failure distinction

**Ordering**:
- Multiple concurrent submissions with same base revision ID → all competing, or timestamp-ordered?
- Can resolution name other resolved revisions as contributing IDs?
- Multiple first submissions (base=null) for same visit ID?

**Concurrency edge cases**:
- Two coordinators submitting different resolutions concurrently?
- Can resolution name only one contributing revision?
- Can resolution omit some competing revisions?

**Boundary conditions**:
- Visit ID doesn't exist AND base revision is non-null?
- Idempotency check timing in validation sequence?
- Can payload fields (species observations, observer lists) be empty?
- Receipt timestamp precision and timezone?

Which gaps should I address in the LLD now, and which should we defer as open questions?