Added `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the record-store LLD’s Decisions & Alternatives table. The decision document covers why field-aware merging remains a credible option, the tradeoffs behind choosing whole-visit revisions, and the obligations for tablet-sync and review-export.

## Decision document

### `docs/intent/record-store/decisions/whole-visit-revisions.md`

---
node: record-store
---

# Decision: Whole-Visit Revisions for Concurrent Edits

## Context

Field workers use shared tablets that can be offline for up to 48 hours. A worker may edit a visit after retrieving it, while another worker independently edits the same visit. A visit contains scientifically related fields—for example, species identification and cover estimate—alongside fields that may be unrelated. The record store cannot reliably infer scientific relationships from field boundaries alone.

Both candidate designs retain the original submissions and their authorship. Either design must preserve enough provenance to explain the exported value. The decision is how to turn concurrent complete-visit edits into a resolved current visit: automatically combine changes classified as disjoint, or preserve complete submissions as competing revisions for coordinator review.

## Decision Elements

1. **Avoid automatically combining edits whose scientific relationship the system cannot establish — major.** The HLD excludes automated inference of scientific intent. A structural difference between fields does not prove that the observations are scientifically independent.
2. **Keep coordinator review work operable — major.** Two coordinators resolve questions about approximately 6,000 visit records per season. Review volume matters, especially when edits are unrelated.
3. **Limit ongoing reconciliation-rule maintenance — moderate.** Any field-aware policy needs rules for scalar fields, observer lists, and species entries, and those rules must continue to reflect scientific relationships as the schema evolves.

## Options in the Domain

### Whole-visit revisions

Each submission contains a complete visit and the revision on which it was based. If its base is still current, the new revision can become current. If another revision has advanced the visit, the complete submission is retained as a competing revision and requires review. The system does not merge fields based on structural independence.

- **Strong — scientific relationship safety:** stale edits are reviewed as complete observations, including edits to fields that appear unrelated.
- **Weak — coordinator workload:** even genuinely unrelated edits create review work, so more visits can remain unresolved until coordinators act.
- **Strong — rule maintenance:** the record store needs revision and review-state logic rather than a maintained taxonomy of mergeable fields and relationships.

### Field-aware three-way merge

Each submission supplies its base snapshot and structured field changes. The record store compares the changes against the current visit, applies changes it classifies as disjoint, and sends overlapping changes to review. It must preserve the source submissions and provenance for the automatically combined result, potentially at field level.

- **Partial — scientific relationship safety:** the policy can detect configured overlaps, but disjoint field paths may still have a scientific relationship that the rules do not encode.
- **Strong — coordinator workload:** edits classified as disjoint can avoid manual review.
- **Weak — rule maintenance:** field-specific merge behavior must be defined and maintained for scalar values, observer lists, species entries, and any cross-field relationships the rules recognize.

## Selection

Use whole-visit revisions. The team accepts a larger review queue rather than maintaining merge rules that could automatically combine scientifically related edits without recognizing their relationship. This prioritizes avoiding unsupported assumptions of field independence over reducing coordinator workload and rule-maintenance cost, and respects the HLD boundary against automated inference of scientific intent. Both options can preserve a traceable path to export: whole-visit revisions keep the current value in one complete submission, while field-aware merging would require reliable field-level provenance to explain a combined value. Retaining each original submission is an invariant for both options, not a differentiator between them.

This choice means that a stale-base edit requires review even when its changed fields appear unrelated. It does not discard the edit: the complete submitted revision and its provenance remain available. The choice also forecloses automatic combination of disjoint field changes in the record store. If review volume proves operationally unsustainable, the team can revisit the policy with observed queue data and explicit scientific relationship rules rather than relying on field separation as evidence of independence.

### Downstream obligations

- **Tablet-sync:** retain the base revision ID with each local edit and submit it with the complete visit. Preserve the server-assigned revision ID returned for accepted submissions, and communicate when an accepted revision is awaiting review. Offline retries must continue to use the same idempotency key and payload so a retry does not create another revision.
- **Review-export:** present competing complete revisions with enough provenance to compare the submitted observations, surface unresolved visits for coordinator review, and exclude unresolved visits from the partner CSV. The exported value must remain traceable to the selected complete revision and its originating submission. The review interface and exact resolution protocol are defined in the review-export design.

The LLD’s remaining edge-case questions are still open for your triage:

1. Should resolution against an outdated review set be rejected if new submissions arrive during coordinator review?
2. Must a coordinator select a submitted revision, or may they author a new complete revision?
3. Should submissions based on the current revision join an already-open review set, as the draft specifies?
4. What should happen when a second initial submission without a base arrives for an existing visit ID?
5. What scope and retention period should apply to idempotency keys?

`git diff --check` passed. Please review the decision document and indicate which of these questions to resolve in the LLD now versus defer. I’ll stop at the Phase 2 review boundary.