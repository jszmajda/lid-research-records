## Phase 2: LLD Review Stop

I've completed the record-store LLD by selecting whole-visit revisions and specifying the downstream contracts. Here's what I've added:

**Completed sections:**
- Full concurrency policy specification (revisions, submission envelope, current-state responses)
- Unresolved-work representation (competing revision lists for review)
- Resolution operation (coordinator selection and notes recording)
- Contracts for tablet-sync and review-export (what each must implement)

**Decisions recorded:**
A Decisions & Alternatives table capturing four key choices: whole-visit revisions vs. field-aware merge, server-assigned revision IDs, base revision ID in envelope, and selection-over-synthetic-merge.

**Tradeoffs documented:**
Why whole-visit revisions preserves scientific intent and avoids merge-rule maintenance, despite the cost of higher review volume. The design explicitly acknowledges field-aware merging as a future upgrade path if coordinators find the review queue becomes a bottleneck.

**Open questions surfaced for resolution:**
Six questions that shape the submission contract and tablet/export workflows:
1. Whether resolution is reversible (coordinator can re-select prior revisions)
2. What state unresolved visits return before any coordinator selection
3. Whether tablets can submit edits when the ancestor base revision is unresolved
4. How to handle submissions referencing base revisions that have been superseded
5. Whether identical independent submissions are deduplicated
6. Whether coordinator selections are immutable or can be reverted

**Downstream constraints:**
Clear lists of what tablet-sync and review-export must accommodate—local base revision tracking, revision comparison views, unresolved-visit exclusion from exports, and handling of state changes as coordinators work.

The design reads context-free (no reliance on this conversation to understand the choice or its implications) and is ready for your judgment on the open questions. Which of these six should we resolve before moving to EARS specs, and how?