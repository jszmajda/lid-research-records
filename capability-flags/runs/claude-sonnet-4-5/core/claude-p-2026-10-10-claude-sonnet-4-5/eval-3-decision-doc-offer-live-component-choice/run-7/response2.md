## Phase 2 Complete: Record-Store Design

The record-store design is now complete with the whole-visit revisions approach fully specified.

### What's New

**Complete contract specifications:**
- **Submission envelope**: Visit ID, base revision ID (nullable), idempotency key (per-visit scoped), worker ID, complete payload
- **Validation rules**: Authentication, structural, base revision, and scientific field validation with specific error codes
- **Error responses**: Full HTTP status code mapping and structured error schema with field-level detail
- **Current-state retrieval**: Three states (resolved, unresolved, not found) with complete JSON response schemas
- **Resolution operation**: Two actions (select existing or combine new) with concurrent resolution handling (last-write-wins)

**Downstream contracts made explicit:**

**Tablet-sync must:**
- Retain base revision IDs locally for offline editing
- Submit complete payloads (~2KB), not deltas
- Handle unresolved state responses (no single current payload exists)
- Display "under review" indicators and competing revisions to workers
- Generate unique idempotency keys per submission

**Review-export must:**
- Exclude unresolved visits from CSV export
- Present revision comparison UI with side-by-side diffs
- Handle ~75-225 reviews/coordinator/week (300-900 total visits/season at 5-15% conflict rate)
- Support both select-existing and manual-combine resolution workflows

**Why field-aware merge remains credible:**

The alternative approach wasn't rejected—it trades different constraints. Field-aware merge would reduce coordinator workload from ~75-225 to ~15-45 reviews/week/person by auto-merging unrelated edits. But it requires:
- Maintained merge rules for scalars, lists, and species-cover arrays
- Provenance tracking showing which fields came from which worker
- Risk that separate-but-related fields (species code + cover estimate) get incorrectly combined

We chose whole-visit revisions because coordinator time is available (seasonal work, two people) and development risk is the binding constraint for first release. The design explicitly documents when to reconsider: if review backlog ages >1 week, concurrent edit rate exceeds 15%, or the team gains confidence in encoding botanical relationship rules.

The design is context-free and ready for the next session—decisions are in the table with rationale, open questions are captured, and downstream nodes have everything they need to proceed with tablet-sync and review-export designs.